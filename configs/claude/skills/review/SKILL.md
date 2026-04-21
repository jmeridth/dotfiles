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

### Drafting comments

- If findings warrant PR comments, draft them in my voice and **show me the draft before posting**
- When specific code changes are needed, use GitHub suggestion blocks
- One actionable point per comment - do not bundle multiple concerns
