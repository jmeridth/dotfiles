---
name: review
description: Review a PR (by link or from current context) or the current feature branch using a multi-model, verification-first workflow.
argument-hint: [pr-url | pr-number | branch]
---

## Code Review Workflow

When asked to review a PR (by link or from current context) or the current feature branch, follow this workflow automatically:

### Multi-model review

- Launch **at least 3 code review agents in parallel** using different available models to get diverse perspectives
- Always display which models were used by each agent
- Synthesize findings across all models - only surface issues that multiple models flag or that can be independently verified
- Present a unified, deduplicated report organized by severity

### Verification standard

- **Every finding must be verified before reporting it.** Do not report potential issues based on assumptions alone.
- Verify by reading the actual source files, checking call sites, tracing data flow, or running tests/experiments
- Clearly label findings with verification status: **Verified** (confirmed by reading code or testing), **Observation** (plausible but depends on context outside the diff), or **Unverified** (could not confirm - include reasoning)
- When a finding involves runtime behavior, write or run a test to confirm it rather than speculating

### What to focus on

- **Correctness over style** - only report bugs, logic errors, security issues, race conditions, type mismatches, and missing edge cases. Do not flag style, formatting, naming conventions, or subjective preferences.
- **Check whether the author has addressed existing review feedback** - read through all review threads and comments before reporting. Note unresolved threads.
- **Check for unintended behavioral changes** - compare new code against the existing patterns in the same file or module
- **Check docstring/comment accuracy** - verify that docstrings, comments, and commit messages accurately describe what the code actually does. Flag cases where stated behavior differs from implemented behavior.

### Tone and voice

- Use additive, curious framing - not corrective or prescriptive
- For **first-time contributors**, lead with what was done well, be warm and specific about how to fix issues, and provide step-by-step guidance rather than terse criticism
- For established contributors or teammates, be concise and direct

### AI attribution

- **Every summary and every PR comment** produced by this skill must start with `:robot:` on the first line so the PR author knows it is an AI-generated review
- **Immediately after the `:robot:` emoji, add a parenthetical tag with the severity, and `non-blocking` only when it applies** — e.g. `:robot: (critical)`, `:robot: (high)`, `:robot: (medium)`, `:robot: (low, non-blocking)`. Severity reflects correctness impact (critical/high/medium/low). **`critical`, `high`, and `medium` are always merge blockers and never get `non-blocking`.** Only `low` (or an other/informational tag) may be marked `non-blocking` — use it for reporting-fidelity gaps, style-adjacent notes, or anything that need not gate the merge.

### Drafting comments

- If findings warrant PR comments, draft them in my voice and **show me the draft before posting**
- When specific code changes are needed, use GitHub suggestion blocks
- One actionable point per comment - do not bundle multiple concerns
- Each comment must begin with `:robot:` per the attribution rule above

### Line-level targeting (mandatory)

- **Every PR comment MUST target a specific line in the diff.** Do not post top-level PR comments for code findings.
- Before posting, parse the diff to get the exact file path and line number for each finding. Use `gh api` or `gh pr diff` to get the current diff and extract line numbers.
- Use the GitHub pull request review comments API (`POST /repos/{owner}/{repo}/pulls/{pull_number}/comments`) with these required fields:
  - `path` - relative file path (e.g. `src/handler.go`)
  - `line` - the line number in the diff's new file side
  - `side` - use `RIGHT` for lines in the new version of the file
  - `body` - the comment text (starting with `:robot:`)
  - `commit_id` - the HEAD commit SHA of the PR
- For multi-line comments, also include `start_line` and `start_side` to highlight a range
- When suggesting a concrete fix, use a GitHub suggestion block in the body:
  ````
  :robot: This could be simplified.
  ```suggestion
  replacementCodeHere()
  ```
  ````
- **Never guess line numbers.** Always derive them from the actual diff output. If you cannot determine the exact line, do not post the comment -- surface it in the summary instead.
