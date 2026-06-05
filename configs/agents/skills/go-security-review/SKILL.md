---
name: go-security-review
description: >
  Security-focused differential review of Go code changes with regression test generation.
  Use when reviewing PRs that modify Go files touching HTTP handlers, file operations,
  exec calls, SQL queries, auth logic, or crypto. Generates concrete regression tests
  that prove each vulnerability.
---

# Go Security Review

Security-focused code review for Go PRs. Every confirmed finding produces a regression test.

## Rationalizations (Do Not Skip)

| Rationalization | Why It's Wrong | Required Action |
|-----------------|----------------|-----------------|
| "Small diff, quick review" | Heartbleed was 2 lines | Classify by RISK, not size |
| "It's just a refactor" | Refactors break invariants | Analyze as HIGH until proven LOW |
| "No user input in this diff" | Input may enter upstream | Read surrounding file before concluding |
| "filepath.Clean handles it" | Clean does NOT prevent traversal | Verify full sanitization chain |
| "Tests exist, it's fine" | Tests may not cover adversarial input | Check for exploit payloads in tests |

---

## Quick Reference

### Risk Triggers

| Risk | Go Patterns |
|------|-------------|
| **HIGH** | `exec.Command`, `os/exec`, `sql.Query` with string concat, `os.Open`/`ReadFile`/`Create` with variable paths, `http.ServeFile`, `template.HTML`, `crypto/` changes, auth middleware changes, `reflect.`, `unsafe.` |
| **MEDIUM** | New HTTP handlers, `json.Unmarshal` into interface{}, exported API changes, `os.Getenv` in security paths, cookie/session handling |
| **LOW** | Logging, comments, test-only files, generated code, vendored deps |

### Input Sources (Go-Specific)

| Source | Functions |
|--------|-----------|
| HTTP | `r.URL.Query()`, `r.FormValue()`, `r.PathValue()`, `r.Header.Get()`, `r.Body`, `mux.Vars()`, `chi.URLParam()`, `gin.Context.Param/Query`, `echo.Context.Param/QueryParam` |
| Files | `filepath.Join()` with variable args, archive entry names (`zip.File.Name`, `tar.Header.Name`) |
| CLI | `os.Args`, `flag.*`, `cobra.Command`, `pflag.*` |
| Deserialization | `json.Unmarshal`, `yaml.Unmarshal`, `gob.Decode`, `xml.Unmarshal`, `proto.Unmarshal` |

### Sensitive Sinks (Go-Specific)

| Category | Functions |
|----------|-----------|
| File ops | `os.Open`, `os.ReadFile`, `os.Create`, `os.WriteFile`, `os.Remove`, `os.MkdirAll`, `os.Rename`, `os.Symlink`, `http.ServeFile` |
| Exec | `exec.Command`, `exec.CommandContext`, `syscall.Exec` |
| SQL | `db.Query`, `db.Exec`, `db.QueryRow` with string formatting |
| Network | `http.Get`, `http.Post`, `http.NewRequest` with variable URLs |
| Templates | `template.HTML()`, `template.JS()`, `template.URL()` type conversions |

---

## Workflow

```
Phase 0: Triage ──> Phase 1: Trace ──> Phase 2: Validate
                                             │
                              ┌───────────────┤
                              ▼               ▼
                    Phase 3: Adversarial   (LOW → stop)
                              │
                              ▼
                    Phase 4: Test + Report
```

### Phase 0: Triage

1. List all changed Go files (exclude `_test.go`, `// Code generated`, vendored)
2. Risk-score each file using the table above
3. If all files are LOW risk, state "No security-relevant changes" and stop
4. For HIGH/MEDIUM files, proceed to Phase 1

### Phase 1: Trace Data Flow

For each HIGH/MEDIUM file:

1. Identify input sources in the diff (see table above)
2. Identify sensitive sinks in the diff (see table above)
3. For each source, trace forward: follow through assignments, function args, returns
4. For each sink, trace backward: where does the argument come from?
5. If flow crosses file boundaries, read the referenced files before concluding
6. Record each source-to-sink path with intermediate steps

**If no source-to-sink path exists, stop. Do not flag code with no data flow.**

### Phase 2: Validate Sanitization

For each source-to-sink path, check if sanitization between them is **correct and sufficient**. Load the relevant reference:

| Vulnerability Class | Reference |
|-------------------|-----------|
| Path traversal (CWE-22) | `read_skill_reference("go-security-review", "references/path-traversal.md")` |

Assign confidence per the false-positive rules:
- `read_skill_reference("go-security-review", "references/false-positives.md")`

### Phase 3: Adversarial Analysis

For each finding with confidence 8+, model the attack:

```
ATTACKER: [Who — unauthenticated user, authenticated user, admin]
ENTRY:    [Exact function/endpoint they can reach]
PAYLOAD:  [Concrete exploit string or value]
FLOW:     [source] → [step] → [step] → [sink]
IMPACT:   [Specific outcome — file read, RCE, data leak, auth bypass]
```

Verify the attacker can actually reach the entry point. If the function is unexported and only called with trusted data, downgrade to Suspicious and do not generate a test.

### Phase 4: Test + Report

For every finding with confidence 8+, generate a regression test that includes a report entry inside of it.

- Example test report comment format:
  // SECURITY FINDING: Path Traversal in `ServeFile` {
  //   Description: Untrusted input from `r.URL.Query().Get("file")` flows into `http.ServeFile` without sanitization, allowing an attacker to read arbitrary files on the server.
  //   Risk: HIGH
  //   Confidence: 9
  //   Exploit: An attacker can send a request to `/download?file=../../../../etc/passwd` to read the server's password file.
  // }

---

## References

Load on demand — do not read all references upfront.

| Reference | When to Load |
|-----------|-------------|
| [path-traversal.md](references/path-traversal.md) | Diff contains file operations with variable paths |
| [false-positives.md](references/false-positives.md) | Before finalizing any finding — apply exclusion rules |
| [reporting.md](references/reporting.md) | When generating the final report and regression tests |
| [methodology.md](references/methodology.md) | For complex PRs needing full phase-by-phase guidance |
