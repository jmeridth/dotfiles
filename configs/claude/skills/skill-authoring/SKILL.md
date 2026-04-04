---
name: skill-authoring
description: Enforces agentskills.io specification for Agent Skills. Use when creating, reviewing, or fixing SKILL.md files, validating skill frontmatter, checking skill directory structure, or auditing skill quality.
---

# Skill Authoring Standards

Use this skill when reviewing or fixing SKILL.md files and skill directory structures. Each section describes a requirement from the [agentskills.io specification](https://agentskills.io/specification) with correct and incorrect examples. When reviewing, flag violations. When fixing, apply the correct pattern.

## Frontmatter

### SKILL.md Must Start with YAML Frontmatter

The file must begin with `---`, followed by YAML, followed by another `---`.

Correct:
```markdown
---
name: my-skill
description: What this skill does and when to use it.
---

# My Skill
...
```

Wrong - no frontmatter:
```markdown
# My Skill

This skill does something...
```

Wrong - frontmatter not at start of file:
```markdown

---
name: my-skill
description: What this skill does.
---
```

### Required Field: `name`

The `name` field is required and must follow strict formatting rules:
- 1-64 characters
- Lowercase letters, numbers, and hyphens only
- Must not start or end with a hyphen
- Must not contain consecutive hyphens

Correct:
```yaml
name: pdf-processing
name: code-review
name: data-analysis
name: my-skill-v2
```

Wrong:
```yaml
name: PDF-Processing     # uppercase not allowed
name: -pdf               # cannot start with hyphen
name: pdf-               # cannot end with hyphen
name: pdf--processing    # consecutive hyphens not allowed
name: my skill           # spaces not allowed
name: my_skill           # underscores not allowed
name: claude-helper      # "claude" is reserved
name: anthropic-tools    # "anthropic" is reserved
```

### Required Field: `description` (most important)

The `description` is the most important part of the skill — it determines whether Claude loads the skill. It is required (1-1024 characters). Structure it as:

```
[What it does] + [When to use it] + [Key capabilities]
```

Include specific trigger phrases — the actual words users would type. Mention relevant file types if applicable.

Correct:
```yaml
description: Go coding standards for this repository. Use when reviewing or fixing Go code to enforce syntax preferences, library choices, code quality checks, package design, and testing conventions.
```

```yaml
description: Analyzes Figma design files and generates developer handoff documentation. Use when user uploads .fig files, asks for "design specs", "component documentation", or "design-to-code handoff".
```

```yaml
description: Manages Linear project workflows including sprint planning, task creation, and status tracking. Use when user mentions "sprint", "Linear tasks", "project planning", or asks to "create tickets".
```

Wrong - too vague, missing "when to use it":
```yaml
description: Helps with PDFs.
```

Wrong - only says what, not when:
```yaml
description: Validates Go code against coding standards.
```

Wrong - too technical, no user triggers:
```yaml
description: Implements the Project entity model with hierarchical relationships.
```

**Audit:** Check that every `description` contains both a "what it does" clause and a "when to use it" / "Use when" clause. Verify the description includes specific keywords matching real user intent (e.g., "PDF", "forms", "extraction") rather than only API terminology.

### Security: No XML Angle Brackets in Frontmatter

Never use `<` or `>` characters in any frontmatter field. Frontmatter is loaded into Claude's system prompt, and angle brackets could enable prompt injection.

Wrong:
```yaml
description: Handles <user> input and <admin> commands.
```

Correct:
```yaml
description: Handles user input and admin commands.
```

**Audit:** Search frontmatter fields for `<` or `>` characters. Flag any occurrences.

### Optional Fields Must Follow Constraints

| Field | Constraint |
|-------|-----------|
| `license` | Keep brief (license name or reference to bundled file) |
| `compatibility` | Max 500 characters. Only include if skill has specific environment requirements |
| `metadata` | Map of string keys to string values only |
| `allowed-tools` | Comma-separated string or YAML list of pre-approved tools (experimental) |

Correct — comma-separated string:
```yaml
license: Apache-2.0
compatibility: Requires git, docker, and network access
metadata:
  author: platform-team
  version: "1.0"
allowed-tools: Bash(git:*), Read
```

Correct — YAML list:
```yaml
allowed-tools:
  - Bash(git:*)
  - Read
```

Wrong - metadata values must be strings:
```yaml
metadata:
  version: 1.0        # Must be quoted: "1.0"
  tags: [a, b, c]     # Must be string, not list
```

Wrong - compatibility too detailed when not needed:
```yaml
# Don't include compatibility if there are no special requirements
compatibility: Works everywhere with no special requirements
```

## Directory Structure

### Skill Directory Must Contain SKILL.md

Every skill is a directory containing at minimum a `SKILL.md` file. The directory name defines the skill identity.

Correct:
```
my-skill/
└── SKILL.md
```

Wrong - missing SKILL.md:
```
my-skill/
└── README.md
```

### SKILL.md Filename is Case-Sensitive

The file must be named exactly `SKILL.md`. No variations are accepted.

Wrong:
```
my-skill/
└── skill.md          # Wrong case
```
```
my-skill/
└── SKILL.MD          # Wrong extension case
```

### Never Include README.md Inside a Skill Folder

All documentation goes in `SKILL.md` or `references/`. Do not add a README.md to the skill directory — it will not be loaded by agents.

Wrong:
```
my-skill/
├── SKILL.md
└── README.md         # Will be ignored by agents
```

### Directory Name Must Match `name` Field

The `name` field in frontmatter must exactly match the parent directory name. This is required by the agentskills.io spec.

Correct:
```
pdf-processing/
└── SKILL.md  # name: pdf-processing
```

Wrong - name doesn't match directory:
```
pdf-processing/
└── SKILL.md  # name: pdf-processor
```

**Audit:** For each skill directory, verify that the `name:` field in frontmatter matches the directory name.

### Optional Directories Follow Conventions

Only use `references/`, `scripts/`, and `assets/` subdirectories. Never create other top-level subdirectories inside a skill directory.

Correct:
```
my-skill/
├── SKILL.md
├── references/          # Additional documentation
│   └── detailed-guide.md
├── scripts/             # Executable code
│   └── helper.sh
└── assets/              # Static resources
    └── template.yaml
```

Wrong - non-standard subdirectory:
```
my-skill/
├── SKILL.md
├── docs/                # Should be references/
│   └── guide.md
└── lib/                 # Should be scripts/
    └── helper.py
```

**Audit:** Check that skill directories only contain `SKILL.md` and the optional `references/`, `scripts/`, and `assets/` subdirectories.

## Body Content

### Body Must Contain Actionable Instructions

The Markdown body after frontmatter contains skill instructions. Always include:

- Step-by-step instructions with direct commands (use "Always do X" not "X is recommended")
- Concrete correct and incorrect examples for every rule
- Common edge cases with explicit handling guidance

Correct:
```markdown
---
name: my-skill
description: ...
---

# My Skill

Use this skill when [trigger condition]. Each section describes a standard
with correct and incorrect examples.

## Section Name

### Rule Name

Description of the rule.

Correct:
\```
good example
\```

Wrong:
\```
bad example
\```

**Audit:** How to find violations of this rule.
```

Wrong - body with no actionable content:
```markdown
---
name: my-skill
description: ...
---

# My Skill

This skill is about something. See the docs for more info.
```

### Use Directives, Not Implications

Always write instructions as direct commands. Models follow explicit directives better than they infer implications.

Correct:
```markdown
Always use `interactions.create()` for new conversations.
Never call the deprecated `chat()` method.
```

Wrong - implies rather than instructs:
```markdown
The Interactions API is the recommended approach for new conversations.
The chat() method is considered deprecated.
```

**Audit:** Search for hedging language ("should", "recommended", "considered", "is preferred"). Replace with direct commands ("Always", "Never", "Use", "Do not").

### Keep SKILL.md Under 500 Lines

Per progressive disclosure, the main SKILL.md should be under 500 lines. Move detailed reference material to `references/` files.

Correct:
```
my-skill/
├── SKILL.md                    # Core rules (~200 lines)
└── references/
    ├── detailed-patterns.md    # Extended examples
    └── edge-cases.md           # Corner cases
```

Wrong - everything in one massive file:
```
my-skill/
└── SKILL.md                    # 1500 lines of content
```

**Audit:** Check line count of SKILL.md files. Flag any over 500 lines and suggest moving detailed content to `references/`.

## Progressive Disclosure

### Structure for Efficient Context Usage

Skills follow a three-tier progressive disclosure model:

1. **Metadata** (~100 tokens): `name` and `description` from frontmatter - loaded at startup for all skills
2. **Instructions** (<5000 tokens recommended): Full SKILL.md body - loaded when skill is activated
3. **Resources** (as needed): Files in `references/`, `scripts/`, `assets/` - loaded only when required

**Audit:** Verify that SKILL.md body stays under ~5000 tokens. Detailed documentation, long examples, and reference material should be in `references/` files.

### Reference Files Must Be Focused

Each file in `references/` must cover a single topic. Keep file references one level deep from SKILL.md. Never create deeply nested reference chains.

Correct:
```markdown
For detailed patterns, see [patterns guide](references/patterns.md).
```

Wrong - deeply nested references:
```markdown
See [guide](references/advanced/deep/nested/guide.md).
```

Wrong - reference file covers too many topics:
```
references/
└── everything.md    # 2000 lines covering 10 different topics
```

## Common Anti-Patterns

For detailed anti-patterns with examples and fixes, see [anti-patterns reference](references/anti-patterns.md). Key anti-patterns to watch for:

- **Generic description** — vague descriptions that won't trigger reliably
- **No examples in body** — rules without concrete correct/incorrect examples
- **Name mismatch** — `name` field doesn't match directory name
- **API terminology in description** — uses internal names instead of user intent
- **Implications instead of directives** — hedging language ("recommended") instead of commands ("Always")
- **Missing audit instructions** — rules without guidance on how to detect violations

## Skill Quality Checklist

Before submitting a skill, verify:

- [ ] File is named exactly `SKILL.md` (case-sensitive)
- [ ] `SKILL.md` starts with valid YAML frontmatter (`---` delimiters)
- [ ] No XML angle brackets (`<` or `>`) in any frontmatter field
- [ ] `name` field matches parent directory name exactly
- [ ] `name` follows format rules (lowercase, hyphens, 1-64 chars, no consecutive hyphens)
- [ ] `name` does not contain "claude" or "anthropic" (reserved)
- [ ] `description` follows formula: [What it does] + [When to use it] + [Key capabilities]
- [ ] `description` includes trigger phrases matching real user intent
- [ ] Body contains actionable instructions with concrete examples
- [ ] Correct and incorrect examples are provided for each rule
- [ ] Instructions use directives ("Always", "Never", "Use") not implications ("recommended", "preferred")
- [ ] SKILL.md is under 500 lines
- [ ] Detailed content is in `references/` files, not crammed into SKILL.md
- [ ] No README.md inside the skill directory
- [ ] Only standard subdirectories used (`references/`, `scripts/`, `assets/`)
- [ ] Reference files are focused (one topic per file)
- [ ] No deeply nested reference chains
