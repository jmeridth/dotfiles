# Reporting and Test Generation

## Output Format

Every confirmed finding (confidence 8+) produces exactly one artifact: a **regression test with the security finding embedded as a structured comment**. No separate report document — the test IS the report.

This means:
- Findings are version-controlled alongside the code they protect
- Findings are machine-parseable (structured comment block)
- The test proves the vulnerability exists and prevents regression
- CI enforces that the finding stays fixed

## Go Test Style

Follow the conventions in the `go-standards` skill for general Go test formatting:
- Table-driven tests with descriptive sub-test names
- `got`/`want` error message format
- `cmp.Diff` for complex values with `(-want, +got)` ordering
- `t.Context()` instead of `context.Background()`
- `t.TempDir()` for temporary directories (auto-cleaned)

For details: `read_skill_reference("go-standards", "references/testing-patterns.md")`

---

## Test File Convention

- File: `security_test.go` in the same package as the vulnerable code
- If `security_test.go` already exists, append to it
- Each finding gets two test functions: one proving the vuln, one proving legitimate access still works

---

## Test Structure

```go
// SECURITY FINDING: <Title> in `<FunctionName>` {
//   CWE: CWE-<number>
//   Description: <One-sentence description of the vulnerability with source and sink>
//   Risk: HIGH | MEDIUM
//   Confidence: <8-10>
//   Attacker: <Who — unauthenticated user, authenticated user, admin>
//   Entry: <Exact function or HTTP route>
//   Flow: <source> → <intermediate steps> → <sink>
//   Exploit: <Concrete exploit scenario in one sentence>
//   Impact: <Specific outcome — what the attacker achieves>
// }
func TestVuln_CWE<number>_<BriefDescription>(t *testing.T) {
    // Setup
    // ... create temp dirs, test servers, etc.

    // Exploit payload
    payload := "<concrete exploit value>"

    // Attempt exploit
    result, err := vulnerableFunction(payload)

    // Assert: if exploit succeeds, the vulnerability exists
    if err == nil {
        t.Errorf("<vulnerability type> not blocked for payload %q: got %v", payload, result)
    }
}

// Companion test: verify legitimate access still works after a fix
func TestSafe_CWE<number>_<BriefDescription>(t *testing.T) {
    // Setup with safe, legitimate input
    // ... same setup as above

    result, err := vulnerableFunction("legitimate-input")
    if err != nil {
        t.Fatalf("legitimate access blocked: %v", err)
    }
    // Assert expected result
    _ = result
}
```

---

## Test Requirements

1. **Compiles and passes `go vet`** — always verify before submitting
2. **Concrete exploit payload** — never theoretical ("an attacker could..."), always a real value (`"../../etc/passwd"`)
3. **Fails on vulnerable code** — the test must prove the vulnerability by succeeding when the bug exists
4. **Passes after fix** — the test becomes a regression guard once the vulnerability is patched
5. **Self-contained** — uses `t.TempDir()`, `httptest.NewServer()`, and other stdlib test utilities. No external dependencies or network calls.
6. **Table-driven for multiple payloads** — when testing bypass variants, use subtests:

```go
func TestVuln_CWE22_PathTraversalVariants(t *testing.T) {
    // SECURITY FINDING: Path Traversal in `serveFile` {
    //   CWE: CWE-22
    //   Description: User-controlled filename from query parameter flows into os.ReadFile without path validation.
    //   Risk: HIGH
    //   Confidence: 9
    //   Attacker: Unauthenticated user
    //   Entry: GET /download?file=<payload>
    //   Flow: r.URL.Query().Get("file") → filepath.Join(baseDir, file) → os.ReadFile
    //   Exploit: GET /download?file=../../../etc/passwd reads server files
    //   Impact: Arbitrary file read from server filesystem
    // }

    baseDir := t.TempDir()
    os.WriteFile(filepath.Join(baseDir, "ok.txt"), []byte("safe"), 0644)

    payloads := []string{
        "../../../etc/passwd",
        "..\\..\\..\\etc\\passwd",
        "subdir/../../etc/passwd",
        "....//....//etc/passwd",
    }

    for _, p := range payloads {
        t.Run(p, func(t *testing.T) {
            _, err := serveFile(baseDir, p)
            if err == nil {
                t.Errorf("path traversal not blocked: %q", p)
            }
        })
    }
}
```

---

## What Makes a Good Exploit Payload

| Vulnerability | Good Payload | Bad Payload |
|--------------|-------------|-------------|
| Path traversal | `"../../../etc/passwd"` | `"malicious path"` |
| Command injection | `"; cat /etc/passwd #"` | `"bad command"` |
| SQL injection | `"' OR 1=1 --"` | `"sql attack"` |
| SSRF | `"http://169.254.169.254/metadata"` | `"internal url"` |
| Template injection | `"{{.System \"id\"}}"` | `"template attack"` |

The payload must be something an attacker would actually send. If you can't write a concrete payload, the finding is probably below confidence 8.

---

## When NOT to Generate a Test

- Confidence below 8 — note it in review comments instead
- Vulnerability requires runtime conditions you can't reproduce in a unit test (e.g., specific cloud IAM configuration)
- The vulnerable function is not callable from the test package (unexported, no test helper access)
- The fix requires architectural changes, not a code patch — describe the issue in review comments with a recommendation

In these cases, leave a review comment with the SECURITY FINDING block but without a test function.
