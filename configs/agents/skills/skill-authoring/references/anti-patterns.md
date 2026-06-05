# Common Anti-Patterns

## Anti-Pattern: Generic Description

```yaml
# WRONG
description: A helpful skill.
```

**Fix:** Describe what the skill does AND when to use it with specific keywords.

## Anti-Pattern: No Examples in Body

```markdown
# WRONG - tells agents what to do but not how
## Rules
- Follow coding standards
- Use best practices
- Write clean code
```

**Fix:** Include concrete correct/incorrect examples for every rule.

## Anti-Pattern: Name Mismatch

```yaml
# WRONG - directory is "code-review" but name says "code-reviewer"
name: code-reviewer
```

**Fix:** Ensure `name` exactly matches the parent directory name.

## Anti-Pattern: Description Uses API Terminology Instead of User Intent

```yaml
# WRONG - uses internal API names that users won't type
description: Wraps the InteractionService.Create RPC for conversational agents.
```

**Fix:** Match how users describe the task: "Creates conversational AI agents with streaming responses. Use when building chatbots, assistants, or any interactive AI feature."

## Anti-Pattern: Implications Instead of Directives

```markdown
# WRONG - hedging language that models may not follow reliably
It is recommended to use constants for configuration values.
The preferred approach is to validate inputs early.
```

**Fix:** Replace with direct commands: "Always use constants for configuration values." / "Validate all inputs at function entry."

## Anti-Pattern: Missing Audit Instructions

Rules without audit instructions make it harder for reviewers to systematically find violations.

```markdown
# WRONG - no audit guidance
## Use Constants

Use named constants instead of magic numbers.
```

**Fix:** Add an **Audit:** section explaining how to search for violations.
