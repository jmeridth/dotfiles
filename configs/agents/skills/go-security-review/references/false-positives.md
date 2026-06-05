# False Positive Filtering

Adapted from [Anthropic's security review methodology](https://github.com/anthropics/claude-code-security-review). Apply these rules before reporting any finding. Better to miss a theoretical issue than flood the report with noise.

## Confidence Scoring

Every finding requires a confidence score from 1-10:

| Score | Meaning | Action |
|-------|---------|--------|
| 9-10 | Certain exploit path, concrete payload identified | Report + generate test |
| 8 | Clear vulnerability pattern with known exploitation methods | Report + generate test |
| 7 | Suspicious pattern requiring specific conditions | Note for human review, no test |
| 1-6 | Speculative or theoretical | Do not report |

Only report findings scoring 8 or above.

## Hard Exclusions

Never report findings matching these patterns, regardless of confidence:

1. **Denial of Service** — resource exhaustion, algorithmic complexity, memory consumption. These are managed separately.
2. **Test files** — files ending in `_test.go` are not production attack surface. Do not flag vulnerable patterns in tests unless the test itself introduces a production vulnerability (e.g., a test helper that gets compiled into production).
3. **Generated code** — files with `// Code generated` headers. Flag the generator, not the output.
4. **Constant/literal arguments** — `os.Open("config.yaml")`, `filepath.Join(baseDir, "known.txt")` where every component is a string literal or constant. No user control = no vulnerability.
5. **Parameterized SQL** — `db.Query("SELECT * FROM users WHERE id = $1", id)` is the safe pattern. Only flag string concatenation/formatting into SQL.
6. **crypto/rand** — this is the correct randomness source. Do not confuse with `math/rand`.
7. **Environment variables and CLI flags as attacker input** — `os.Getenv()` and `flag.String()` values are trusted in standard threat models. Only flag if the code explicitly documents untrusted environment (e.g., container escape scenarios).
8. **Race conditions without concrete exploit path** — only report TOCTOU if you can describe the exact interleaving that causes harm.
9. **Outdated dependencies** — managed by separate tooling (Dependabot, Renovate). Do not report.
10. **Log content** — logging unsanitized user input is not a vulnerability unless it logs secrets or PII. Log injection is not a finding.
11. **Vendored/third-party code** — do not review code under `vendor/`, `third_party/`, or similar directories unless the PR modifies it.
12. **Error message information disclosure** — returning `err.Error()` to users is a code quality issue, not a security vulnerability, unless it leaks secrets or internal paths that enable further exploitation.
13. **Missing rate limiting** — absence of rate limiting is a design concern, not a code vulnerability.

## Go-Specific Safe Patterns

Do not flag these as vulnerabilities:

| Pattern | Why It's Safe |
|---------|--------------|
| `http.Dir` + `http.FileServer` | `http.Dir.Open()` rejects `..` paths |
| `filepath.Join` where ALL args are from trusted config | No user control in the path |
| `template.Must(template.ParseFiles(...))` with constant paths | Templates loaded at init, not from user input |
| `sql.DB.Query` with `$1`/`?` placeholders | Parameterized queries prevent injection |
| Unexported functions called only from trusted callers | Verify call sites — if all callers pass trusted data, not exploitable |

## Precedents

When evaluating edge cases, apply these precedents:

1. **UUIDs are unguessable** — do not require validation of UUID format for security purposes.
2. **Framework middleware handles auth** — in `chi`, `gin`, `echo`, check for auth middleware on the router group before flagging missing per-handler auth.
3. **Frontend frameworks with auto-escaping are XSS-safe** — only flag explicit HTML bypass methods (e.g., explicit raw HTML insertion APIs).
4. **Context values are trusted** — data extracted from `context.Context` was placed there by trusted middleware.
5. **Struct field access after Unmarshal is not injection** — `json.Unmarshal` into a struct with typed fields provides implicit validation. Only flag if the field value flows to a sink without further checks.
