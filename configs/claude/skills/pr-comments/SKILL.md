---
name: pr-comments
description: Fetch, assess, and address PR review comments — fix valid ones, explain why invalid ones are skipped, reply with commit links, and resolve threads.
argument-hint: [pr-url | pr-number | owner/repo#number]
---

## PR Comments Workflow

When invoked, follow this workflow automatically:

### 1. Fetch comments

- Use `gh api repos/{owner}/{repo}/pulls/{number}/comments` to get all review comments
- Use the GraphQL API to get review thread IDs for resolving later
- Read through all comments and group by thread
- Note which threads are already resolved — skip those

### 2. Assess each comment

For each unresolved comment:
- **Read the referenced code** at the file/line indicated by the comment
- **Determine validity**: Is this a real bug, a valid improvement, a style nitpick, or incorrect?
- **Classify the action**:
  - **Fix**: The comment identifies a real issue or a worthwhile improvement — make the code change
  - **Decline**: The comment is incorrect, a style preference, testing framework internals, or out of scope — explain why
- Present a summary table of all comments with the proposed action before proceeding

### 3. Wait for approval

- Show the assessment to the user and wait for confirmation before making changes or posting replies
- The user may override individual assessments (e.g., "skip that one" or "actually fix that")

### 4. Implement fixes

- Make all approved code changes on the current branch
- Run tests and linting to verify nothing is broken
- Commit with `--signoff` using a descriptive message that references the PR comments
- Push to the branch

### 5. Reply and resolve

For each comment, determine if it is a **review thread comment** (inline code comment on the diff) or a **top-level issue comment** (posted on the PR conversation tab):

- Review thread comments have a `pull_request_review_id` and a `path`/`line` — fetch via `gh api repos/{owner}/{repo}/pulls/{number}/comments`
- Top-level issue comments do not — fetch via `gh api repos/{owner}/{repo}/issues/{number}/comments`

**If fixed:**
- Reply with a direct link to the commit that addressed it (e.g., `Addressed in https://github.com/{owner}/{repo}/commit/{sha}`)
- If it is a review thread comment, also resolve the thread via the GraphQL `resolveReviewThread` mutation
- If it is a top-level issue comment (not a thread), quote the original message in the reply using a GitHub blockquote (`> text`) so readers have context without needing to scroll — no resolve step needed

**If declined:**
- Reply with a concise explanation of why the change was not made
- If it is a review thread comment, resolve the thread
- If it is a top-level issue comment, quote the original message in the reply

### Rules

- Never post replies or resolve threads without user approval
- Always run tests and lint before committing
- Always sign off commits
- One commit per batch of comment fixes is fine — no need for one commit per comment unless the changes are unrelated
- If a comment requires a change that conflicts with another comment, flag it to the user
- If a comment references code outside the PR diff, read the full file before assessing
