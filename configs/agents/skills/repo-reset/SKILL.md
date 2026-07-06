---
name: repo-reset
description: Pull latest main, switch to it, then assess and clean up merged branches and worktrees for a given repo
---

## Repo Reset

When invoked with a repo name (e.g., `/repo-reset mono`), perform the following steps in order:

### 1. Resolve the repo path

- Check common locations: `/Users/jason.meridth/code/<repo>`
- If the repo path doesn't exist, ask the user for the correct path

### 2. Fetch and update main

```bash
cd <repo-path>
git fetch upstream main 2>/dev/null || git fetch origin main
git checkout main
git merge upstream/main --ff-only 2>/dev/null || git merge origin/main --ff-only
```

- Prefer `upstream` remote if it exists, fall back to `origin`
- If the merge fails (not fast-forward), STOP and tell the user - do not force reset

### 3. Assess worktrees

- List all worktrees: `git worktree list` (use `git worktree list --porcelain` for parsing)
- The main worktree (the repo path itself, now on `main`) is never touched - skip it
- For every other worktree, gather its state:
  - **Branch**: the branch it has checked out (or "detached")
  - **PR status**: `gh pr list --head <branch> --state merged --json number --jq '.[0].number'` (merged / open / none)
  - **Dirty?**: `git -C <worktree-path> status --porcelain` - non-empty means uncommitted changes or untracked files
  - **Prunable?**: shown as `prunable` in `git worktree list --porcelain`
- Classify each worktree as one of:
  - **Removable** - PR merged AND clean (no uncommitted changes)
  - **Prunable** - the working directory is gone/stale
  - **Skip (open PR)** - branch has an open PR
  - **Skip (no PR)** - branch has no PR (likely local scratch work)
  - **Skip (dirty)** - has uncommitted changes or untracked files

### 4. Clean up worktrees (before deleting branches)

- Remove each **Removable** worktree: `git worktree remove <path>`
- Prune **Prunable** worktrees: `git worktree prune`
- Do this BEFORE branch deletion: `git branch -d` refuses to delete a branch that is checked out in a worktree, so the worktree must go first
- **NEVER force-remove a worktree with uncommitted changes** (no `--force`) - report it as Skip (dirty) and leave it alone

### 5. Delete merged feature branches

- List all local branches except `main` (and `master` if it exists)
- For each branch, check if its associated PR is merged using: `gh pr list --head <branch> --state merged --json number --jq '.[0].number'`
- If the PR is merged, delete the branch: `git branch -d <branch>`
- If the branch has no PR or the PR is still open, skip it and report it
- **NEVER use `git branch -D` (force delete)** - only use `-d` (safe delete)

### 6. Report summary

Print a summary:
```
Repo: <repo-name>
Branch: main @ <short-sha>
Deleted branches: <list or "none">
Skipped branches: <list with reason, or "none">
Worktrees removed: <list or "none">
Worktrees pruned: <count or "none">
Worktrees skipped: <list with reason (open PR / no PR / dirty), or "none">
```
