# Detailed Review Methodology

Extended phase-by-phase workflow for complex PRs. For simple PRs (1-3 files, obvious risk), the quick workflow in SKILL.md is sufficient. Use this reference for PRs touching 5+ files, multiple packages, or architectural changes.

Adapted from [Trail of Bits differential-review methodology](https://github.com/trailofbits/skills).

---

## Pre-Analysis: Baseline Context

Before reviewing changes, understand what the code was supposed to do:

```bash
# What changed?
git diff --stat <base>..<head>
git log --oneline <base>..<head>

# List changed Go files (exclude tests, generated, vendor)
git diff --name-only <base>..<head> | grep '\.go$' | grep -v '_test\.go$' | grep -v 'vendor/'
```

For each changed file, identify:
- What package does it belong to? What does the package do?
- What security invariants exist? (auth checks, input validation, access control)
- What trust boundaries does the code sit on? (HTTP handler, RPC endpoint, internal library)

---

## Phase 0: Triage and Risk Scoring

**Score every changed file:**

| Risk | Triggers |
|------|----------|
| HIGH | Auth/authz logic, crypto operations, exec calls, file ops with variables, SQL with string formatting, HTTP handlers accepting user input, `unsafe` package, `reflect` for deserialization |
| MEDIUM | New exported APIs, business logic changes, config parsing, session/cookie handling, error handling changes |
| LOW | Comments, docs, test-only changes, logging, generated code, vendored deps |

**Classify PR complexity:**

| Size | Strategy |
|------|----------|
| Small (1-5 files) | Deep: read all changed files + their direct dependencies |
| Medium (5-20 files) | Focused: prioritize HIGH files, 1-hop deps for those only |
| Large (20+ files) | Surgical: HIGH risk files only, skip MEDIUM unless connected to HIGH |

---

## Phase 1: Changed Code Analysis

For each HIGH/MEDIUM file, analyze every diff hunk:

```
BEFORE: [exact code removed]
AFTER:  [exact code added]
CHANGE: [what behavior changed]
SECURITY: [implications — new input path? removed validation? weakened check?]
```

**Check removed code carefully:**

```bash
# Why was this code originally added?
git log -S "removed_code_pattern" --all --oneline

# Who added it and when?
git blame <base> -- path/to/file.go | grep "pattern"
```

Red flags for removed code:
- From a commit mentioning "fix", "security", "CVE", "vuln" → CRITICAL regression
- Recently added (<3 months) then removed → investigate why
- Validation/sanitization removed without replacement → HIGH

---

## Phase 2: Cross-Cutting Analysis

Look for patterns across the full diff, not just individual files:

**Validation consistency:**
```bash
# Find all validation patterns in changed files
grep -n 'if.*err\|strings\.HasPrefix\|filepath\.Abs\|regexp\.\|strconv\.' <changed_files>

# Check if any validation was removed
git diff <base>..<head> | grep '^-.*if.*err\|^-.*HasPrefix\|^-.*Abs'
```

**Auth middleware changes:**
```bash
# Check if auth middleware was modified or bypassed
grep -rn 'middleware\|WithAuth\|RequireAuth\|isAuthenticated' <changed_files>
```

**New exported surface:**
```bash
# Find new exported functions (capital letter after func)
git diff <base>..<head> | grep '^+func [A-Z]\|^+.*func.*[A-Z]'
```

---

## Phase 3: Blast Radius

For each HIGH finding, calculate how many callers are affected:

```bash
# Count callers of modified function
grep -rn 'functionName(' --include='*.go' . | grep -v '_test.go' | wc -l
```

| Callers | Blast Radius | Impact on Severity |
|---------|-------------|-------------------|
| 1-3 | Low | Severity unchanged |
| 4-10 | Medium | Elevate by one level |
| 11+ | High | Elevate to Critical if exploitable |

---

## Phase 4: Adversarial Modeling

For each HIGH finding, build a concrete attack:

```
ATTACKER:
  Who:    [Unauthenticated user / Authenticated user / Admin / Compromised service]
  Access: [Public endpoint / Internal API / Requires specific role]
  Entry:  [Exact function or HTTP route]

EXPLOIT:
  Step 1: [Concrete action — exact HTTP request, function call, input value]
  Step 2: [How input reaches the sink — trace through code]
  Step 3: [What happens at the sink — file read, command exec, SQL executed]

PAYLOAD: [Exact exploit string, e.g., "../../etc/passwd"]

IMPACT:
  [Specific outcome: "reads arbitrary files from the server filesystem"]
  [NOT: "could potentially cause issues"]

PROOF OF REACHABILITY:
  - Function is exported / HTTP handler is registered at route X
  - No auth middleware on this route (or attacker has valid credentials)
  - No WAF/proxy rule blocks the payload
```

**Cross-reference with baseline:**
- Does this violate an invariant that existed before the change?
- Does this reintroduce a previously-fixed vulnerability?
- Does this bypass a validation pattern used elsewhere in the codebase?

---

## Phase 5: Generate Tests and Report

Apply reporting format from `reporting.md`. For each confirmed finding:

1. Generate a regression test with concrete exploit payload
2. Generate a companion "safe access" test to prevent over-fixing
3. Write the finding report with attacker model, flow, and impact

Verify every test compiles:
```bash
go vet ./path/to/package/...
```
