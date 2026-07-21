---
name: obsidian-daily
description: Summarize the recent work done in the current Claude context into today's Obsidian daily note (daily/YYYY-MM-DD.md), merging without duplicating. Use when the user says "obsidian daily", "log my work to obsidian", "update my daily note", or asks to record today's work into their Obsidian vault.
---

# Obsidian Daily

Use this skill to append a summary of the current session's work into the user's Obsidian daily note. The daily note is a running log for a staff+ software engineer. Always merge into the existing note; never duplicate content already present.

## Locate the vault and today's file

Always resolve the vault path from `$OBSIDIAN_VAULT`. Never hardcode a vault path.

If `$OBSIDIAN_VAULT` is not set, stop and ask the user for their vault path (and suggest they export `OBSIDIAN_VAULT` so future runs skip the prompt). Do not guess or fall back to a default.

Always compute today's date with the local system clock:

```bash
if [ -z "$OBSIDIAN_VAULT" ]; then
  echo "OBSIDIAN_VAULT is not set" >&2   # ask the user for the vault path before continuing
  exit 1
fi
VAULT="$OBSIDIAN_VAULT"
TODAY="$(date +%F)"          # YYYY-MM-DD
DAILY="$VAULT/daily/$TODAY.md"
```

Never hardcode a date. Never write to a date other than today unless the user explicitly names one.

## Create vs. merge

Always read `$DAILY` first if it exists.

- If `$DAILY` does not exist, seed it from `$VAULT/templates/template_daily.md`, replacing `{{date}}` with today's date and removing the placeholder `{{link}}` example bullets. Then fill in the real content.
- If `$DAILY` exists, merge only. Never rewrite, reorder, or reformat content you did not add in this run.

## What to capture

Summarize only work that actually happened in this session. Pull from:

- Commits made this session (`git log` on branches touched).
- Pull requests opened, reviewed, or updated.
- Linear tickets or GitHub issues worked.
- Notable decisions, tradeoffs, blockers, and learnings surfaced in the conversation.

Never invent work. If a section has nothing real to add, omit that heading entirely rather than writing an empty one.

## Section mapping

Map session work to these headings (matching the vault template):

| Heading | Content |
|---------|---------|
| `## Tickets` | Ticket/issue link + one-line summary of work done |
| `## Reviews` | PR link + results (# findings, severity counts) |
| `## Changes shipped` | PR/commit link + what changed and why (1 line) |
| `## Decisions & tradeoffs` | Decision made, alternative rejected, and why |
| `## Blockers & follow-ups` | `- [ ]` checkbox items for open work / waiting-on / next step |
| `## Notes & learnings` | Anything worth remembering |

## Deduplication rules

Always dedupe before writing. Key each existing entry by its link (ticket URL, PR URL, commit SHA, or branch name).

- If an entry with the same key already exists, do not re-add it.
- If that entry exists but you have new sub-bullets for it, add only the new sub-bullets nested under the existing entry.
- If no matching key exists, append a new entry under the correct heading.
- If a heading is missing from an existing file but you have content for it, add the heading in the template's order.

Correct — session shipped a new PR not yet in the note:
```markdown
## Changes shipped
- https://github.com/org/repo/pull/42 — add retry backoff to webhook sender
```

Correct — ticket already present, only add the new sub-bullet:
```markdown
## Tickets
- https://linear.app/team/issue/ENG-123
	- wired up the config loader        # already there, left untouched
	- added table-driven tests          # new this run
```

Wrong — re-adding a PR already in the note:
```markdown
## Changes shipped
- https://github.com/org/repo/pull/42 — add retry backoff   # existing
- https://github.com/org/repo/pull/42 — add retry backoff   # duplicate, do not do this
```

Wrong — creating a duplicate heading:
```markdown
## Tickets
...
## Tickets      # never add a second heading of the same name
```

## Formatting

- Use tabs for nested sub-bullets, matching the vault template.
- Keep summaries to one line each. This is a log, not a report.
- Use full URLs as links so they render in Obsidian.
- Preserve blank lines between sections.

## After writing

Always report to the user: the file path written, whether it was created or merged, and a short list of what was added (and what was skipped as already present).
