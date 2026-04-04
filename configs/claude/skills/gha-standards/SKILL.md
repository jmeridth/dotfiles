---
name: gha-standards
description: GitHub Actions workflow standards for this repository. Use when reviewing or fixing GitHub Actions workflows to enforce security hardening, permissions, and operational conventions.
---

# GitHub Actions Workflow Standards

Use this skill when reviewing or fixing GitHub Actions workflow files (`.yaml`/`.yml` under `.github/workflows/` and `.github/actions/`). Each section describes a standard with correct and incorrect examples. When reviewing, flag violations. When fixing, apply the correct pattern.

## Security Hardening

### Least-Privilege Permissions

Set `permissions: {}` at the workflow level to deny all permissions by default. Declare only the specific permissions each job needs at the job level, with a comment explaining why each permission is required.

Correct:
```yaml
permissions: {}

jobs:
  build:
    permissions:
      contents: read # Clone the repository
    steps: ...

  deploy:
    permissions:
      contents: read    # Clone the repository
      id-token: write   # Federate via Workload Identity
    steps: ...
```

Wrong - no permissions block (gets broad default permissions):
```yaml
jobs:
  build:
    steps: ...
```

Wrong - workflow-level grants apply to ALL jobs:
```yaml
permissions:
  contents: read
jobs:
  build:
    steps: ...
  deploy:
    steps: ...  # Gets contents:read even if it doesn't need it
```

Wrong - permissions without justification:
```yaml
jobs:
  deploy:
    permissions:
      contents: read
      id-token: write
      security-events: write
    steps: ...
```

**Audit:** Check that every workflow file has a top-level `permissions: {}`, that each job declares its own `permissions` block, and that each permission has a comment explaining why it is needed.

### Use `persist-credentials: false` on Checkout

Always set `persist-credentials: false` on `actions/checkout` unless the job explicitly needs git credentials for subsequent operations (e.g., pushing commits). This prevents the checkout token from being available to later steps that don't need it.

Correct:
```yaml
- uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
  with:
    persist-credentials: false
```

Wrong - persist-credentials defaults to true:
```yaml
- uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
```

**Exception:** When a job needs to `git push` (e.g., dependabot tidy workflows), `persist-credentials: true` is acceptable with a comment explaining why.

**Audit:** Search workflow files for `actions/checkout@` and verify each has `persist-credentials: false` or an explicit comment justifying `true`.

### Use Harden Runner as the First Step

Include `step-security/harden-runner` as the first step in every job to monitor network egress and detect unexpected outbound connections.

Correct:
```yaml
jobs:
  build:
    steps:
      - uses: step-security/harden-runner@fe104658747b27e96e4f7e80cd0a94068e53901d # v2.16.1
        with:
          egress-policy: audit
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
        with:
          persist-credentials: false
```

Wrong - no harden-runner before checkout:
```yaml
jobs:
  build:
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
        with:
          persist-credentials: false
```

**Audit:** Check that every job's first step uses `step-security/harden-runner` with `egress-policy: audit` only if `egress-policy: block` or `policy: mono-{name} # block` are _not_ already being used.

### Never Use `continue-on-error`

Never add `continue-on-error: true` to any step. Suppressing errors masks real failures, makes debugging harder, and can hide security issues. If a step fails due to transient infrastructure errors, fix the root cause or retry the workflow.

Correct:
```yaml
- uses: step-security/harden-runner@a90bcbc6539c36a85cdfeb73f7e2f433735f215b # v2.15.0
  with:
    egress-policy: audit
```

Wrong:
```yaml
- uses: step-security/harden-runner@a90bcbc6539c36a85cdfeb73f7e2f433735f215b # v2.15.0
  continue-on-error: true
  with:
    egress-policy: audit
```

**Exception:** `continue-on-error: true` is acceptable when used as part of a retry pattern, where a subsequent step retries the failed step on failure.

Correct - continue-on-error used for retry (from e2e-kind.yaml):
```yaml
- uses: step-security/workflow-conclusion-action@e624ac1e0582b6498a4ddaa8cf623532fc7b95ea # v3.0.9
  id: workflow-conclusion
  continue-on-error: true

- name: Retry workflow conclusion check on rate limit
  if: steps.workflow-conclusion.outcome == 'failure'
  run: |
    # retry logic with exponential backoff
```

**Audit:** Search workflow files for `continue-on-error: true`. Flag every occurrence that is not part of a retry pattern for removal.

## Operational Conventions

### Use `.yaml` Extension and Set Concurrency

Workflow files must use the `.yaml` extension (not `.yml`). Workflows triggered by `pull_request` must set a `concurrency` group with `cancel-in-progress: true` to avoid redundant runs on superseded commits. The concurrency group must use `github.head_ref || github.ref` so that pull requests are isolated from each other and from post-submit runs. `github.head_ref` is the PR source branch (unique per PR), while `github.ref` for PRs resolves to the target branch (e.g., `refs/heads/main`), which would collapse all PRs into a single group. The `|| github.ref` fallback covers `push` events where `github.head_ref` is empty. Only cancel in-progress runs for `pull_request` triggers — post-submit (`push`) runs should not be cancelled since each commit matters.

Correct - pull request trigger with concurrency:
```yaml
# File: .github/workflows/my-workflow.yaml
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.head_ref || github.ref }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}
```

Wrong - `.yml` extension:
```
.github/workflows/my-workflow.yml
```

Wrong - no concurrency block on a PR-triggered workflow:
```yaml
on:
  pull_request:
    branches: [main]

jobs:
  build:
    steps: ...
```

Wrong - cancels post-submit runs:
```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.head_ref || github.ref }}
  cancel-in-progress: true  # This cancels push runs too
```

Wrong - uses github.ref alone, which is the target branch for PRs and collapses all PRs into one group:
```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

**Exception:** Scheduled-only or `workflow_dispatch`-only workflows may omit `concurrency` if concurrent runs are intentional.

**Audit:** Check file extensions and verify that workflows with `pull_request` triggers include a `concurrency` block using `github.head_ref || github.ref` with `cancel-in-progress` conditioned on the event name.
