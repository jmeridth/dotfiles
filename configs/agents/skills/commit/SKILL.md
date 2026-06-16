---
name: commit
description: Create a meaningful git commit message based on current changes.
argument-hint: [issue-url | issue-id]
---

## Context

- Current status: !`git status`
- Current diff: !`git diff HEAD`
- Current branch: !`git branch --show-current`

## Critical Rules

- **Always ensure you're on a feature branch**
- **Always sign-off my commits** with my git config user.name and user.email
- **Always run tests and lint the code** before creating a git commit
- **NEVER git commit or git push without explicit user approval** - ALWAYS ask first
- **NEVER add any agent as a co-author, only add co-author(s) when the user explicitly requests it**


- Create a meaningful commit message based on the current staged or unstaged changes.
- Ensure it follows the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#summary) specification.
- Use four separate headings (with newlines after each):
  - **What/Why** -- Intent in 1-2 sentences. Combine the what and why into a single concise statement.
  - **Proof it works** -- Tests passed, manual verification steps, or logs.
  - **Risk + AI role** -- Risk tier (low/medium/high) and which parts were AI-generated. If no AI was involved, say so.
  - **Review focus** -- 1-2 specific areas where human reviewer input matters most.
- Avoid stating obvious facts or padding sections.
- If the issue-url or issue-id ($ARGUMENTS) is provided, add `Relates to $ARGUMENTS` as the first line after the commit title to associate the commit to its issue. Use Linear MCP server or GitHub gh cli if available to get issue-url when issue-id is provided
