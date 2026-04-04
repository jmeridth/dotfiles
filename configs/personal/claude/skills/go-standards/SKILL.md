---
name: go-standards
description: Go coding standards for this repository. Use when reviewing or fixing Go code to enforce syntax preferences, library choices, code quality checks, package design, and testing conventions.
---

# Go Coding Standards

Use this skill when reviewing or fixing Go code. Each section describes a standard with correct and incorrect examples. When reviewing, flag violations. When fixing, apply the correct pattern.

## Go Version

This repository's minimum Go version is defined in the governing `go.mod` file. If you need to verify which language features are available, read the `go` directive from `go.mod`. Do NOT flag valid Go syntax as a compatibility concern without checking.

## REQUIRED File Audit (check FIRST)

**Before reviewing code quality, check that EVERY package directory contains these files. These are the most commonly missed violations — check for them FIRST.**

REQUIRED: Every directory containing `.go` files MUST also contain (unless it is a `main` package — `main` packages are excluded from these requirements):
1. **`doc.go`** — MUST exist. If missing, report as violation at path `<package-dir>`, line 0.
2. **`example_*test.go`** — MUST exist with Example functions that call all public APIs (e.g., `example_test.go`). If missing, report as violation at path `<package-dir>`, line 0.

**Audit:** For each directory under review, list the files first and check the `package` declaration. If the package is `main`, skip the doc.go and example_test.go checks. Otherwise, if `doc.go` is absent, flag it immediately. If no file matching `example_*test.go` is present, flag it immediately. Do NOT skip these checks even if the code itself is clean — missing files are independent violations.

## Syntax and Style

### Sets Use `map[T]struct{}`

For sets (collections tracking membership), use `map[T]struct{}` instead of `map[T]bool`. The `struct{}` type has zero memory overhead.

✅ **Correct:**
```go
seen := make(map[string]struct{})
seen["key"] = struct{}{}
if _, exists := seen["key"]; exists {
    // found
}
```

❌ **Wrong:**
```go
seen := make(map[string]bool)
seen["key"] = true
if seen["key"] {
    // found
}
```

### Compile-Time Interface Assertions

Use `var _ Interface = (*Type)(nil)` to assert a type implements an interface at compile time. Use a nil pointer cast to avoid allocating an instance.

✅ **Correct:**
```go
var _ fs.FS = (*MyFS)(nil)
var _ io.Reader = (*MyReader)(nil)
```

❌ **Wrong:**
```go
var _ fs.FS = MyFS{}   // allocates a value
var _ fs.FS = &MyFS{}  // allocates a value on the heap
```

### Prefer Range Syntax

Use Go's range syntax over counted loops. Use `for range n` for simple repetition, `for i := range n` when you need the index, and `for _, item := range slice` for iteration.

✅ **Correct:**
```go
for range 10 { doWork() }
for i := range items { process(i) }
for _, item := range items { handle(item) }
```

❌ **Wrong:**
```go
for i := 0; i < 10; i++ { doWork() }
for i := 0; i < len(items); i++ { process(i) }
```

### Specify Capacity in `make()`

When using `make()` for slices and maps where you know the expected capacity, specify it to avoid reallocations.

✅ **Correct:**
```go
results := make([]string, 0, len(input))
lookup := make(map[string]int, len(items))
```

❌ **Wrong:**
```go
results := make([]string, 0)
lookup := make(map[string]int)
```

### Eliminate Single-Use Variables

When a variable is declared and used only once immediately after, pass the value directly.

✅ **Correct:**
```go
return client.Call(&Request{
    Field: "value",
})
```

❌ **Wrong:**
```go
req := &Request{
    Field: "value",
}
return client.Call(req)
```

**Audit:** Search `.go` files for `:= &` and `:= .*\{` to find struct assignments that can be inlined.

### Return Directly Instead of Error Check and Return

When a function returns values and an error, and the caller just checks the error and returns the same values, return the call directly. This does not apply when the error path adds context via `fmt.Errorf` wrapping.

✅ **Correct — direct return:**
```go
return bar()
```

✅ **Correct — error wrapping justifies the intermediate variable:**
```go
foo, err := bar()
if err != nil {
    return foo, fmt.Errorf("doing bar: %w", err)
}
return foo, nil
```

❌ **Wrong — unwrapped pass-through:**
```go
foo, err := bar()
if err != nil {
    return foo, err
}
return foo, nil
```

### Use `net/http` Status Code Constants

Use named constants from the `net/http` package instead of hardcoded numeric HTTP status codes. Named constants are self-documenting and less error-prone.

✅ **Correct:**
```go
import "net/http"

http.Error(w, "not found", http.StatusNotFound)
w.WriteHeader(http.StatusOK)
if resp.StatusCode == http.StatusUnauthorized {
    // handle unauthorized
}
```

❌ **Wrong:**
```go
http.Error(w, "not found", 404)
w.WriteHeader(200)
if resp.StatusCode == 401 {
    // handle unauthorized
}
```

**Audit:** Search `.go` files for hardcoded status codes like `\b(200|201|204|301|302|400|401|403|404|405|409|500|502|503)\b` in contexts where `net/http` constants should be used instead.

### Signal-Handling Context in `main`

In `main` functions, create a context that cancels on interrupt/termination signals using `signal.NotifyContext`. This ensures graceful shutdown without manual signal channel management.

✅ **Correct:**
```go
func main() {
    ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
    defer cancel()

    if err := run(ctx); err != nil {
        slog.ErrorContext(ctx, "run failed", "error", err)
        os.Exit(1)
    }
}
```

❌ **Wrong:**
```go
func main() {
    ctx := context.Background() // no signal handling — won't shut down gracefully

    if err := run(ctx); err != nil {
        log.Fatalf("run: %v", err)
    }
}
```

## Preferred Libraries

**Scope rule:** Only flag library-related violations when the code ALREADY uses or imports the relevant library. Specifically:
- **slog**: Only flag if code uses `log.Printf`/`log.Println`/`fmt.Println` for application logging — do NOT flag code that has no logging at all.
- **go-envconfig**: Only flag if code reads environment variables (e.g., `os.Getenv`, `os.LookupEnv`, `kelseyhightower/envconfig`) — do NOT suggest adding envconfig to code that doesn't handle environment variables at all.
- **signal.NotifyContext**: Only flag if `main()` creates a `context.Background()` — do NOT flag non-main packages or code that doesn't create contexts.

### Logging: slog

Use `log/slog` from the standard library for structured, context-aware logging (available since Go 1.21). Always prefer the `*Context` variants so the context propagates through the call chain.

- Single statement: `slog.InfoContext(ctx, "message")`
- Structured fields: pass key-value pairs as variadic args — `slog.InfoContext(ctx, "msg", "key", val)`
- Format strings: use `fmt.Sprintf` — `slog.InfoContext(ctx, fmt.Sprintf("processing %q", name))`
- Persistent fields on a sub-logger: `logger := slog.Default().With("key", val)` — pass the logger explicitly or store it in context
- Never use `log.Printf`, `log.Println`, or `fmt.Println` for application logging

For detailed examples, see [logging patterns](references/logging-patterns.md).

**Audit:** Search `.go` files for `log\.Printf`, `log\.Println`, and `fmt\.Println` used as application logging. Replace with the appropriate `slog.*Context` call.

### Container Images: go-containerregistry

Use `github.com/google/go-containerregistry` for validating image references, pulling, pushing images, and handling auth.

✅ **Correct:**
```go
import (
    "github.com/google/go-containerregistry/pkg/name"
    "github.com/google/go-containerregistry/pkg/v1/remote"
)

ref, err := name.ParseReference(imageRef)
if err != nil {
    return fmt.Errorf("parsing image reference: %w", err)
}
img, err := remote.Image(ref, remote.WithAuthFromKeychain(authn.DefaultKeychain))
```

❌ **Wrong:**
```go
// Do not shell out to docker or implement custom registry auth
cmd := exec.Command("docker", "pull", imageRef)
if err := cmd.Run(); err != nil {
    return fmt.Errorf("pulling image: %w", err)
}
```

### Environment Config: go-envconfig

Use `github.com/sethvargo/go-envconfig` for environment variable configuration. In `main` packages, declare config as a global `var` using `MustProcess` with an anonymous struct. This reads env vars at startup and panics immediately if required values are missing — no error handling boilerplate needed.

```go
var env = envconfig.MustProcess(context.Background(), &struct {
    Port      int           `env:"PORT,default=8080"`
    DBHost    string        `env:"DB_HOST,required"`
    RetryWait time.Duration `env:"RETRY_WAIT,default=3s"`
}{})
```

Only use this pattern in `main` packages. Library packages must accept configuration as function/constructor parameters instead of reading from the environment directly.

⚠️ **Do not combine `required` and `default` on the same field** — `go-envconfig` will error with `ErrRequiredAndDefault`.

### Migrating from Kelsey Hightower's envconfig

Code using `github.com/kelseyhightower/envconfig` must be migrated to `github.com/sethvargo/go-envconfig`. For the full migration guide including struct tag changes, processing changes, and `go.mod` updates, see [envconfig migration](references/envconfig-migration.md).

### Container Builds: ko

Use `ko` (https://ko.build) for building container images from Go, not Dockerfiles or docker-compose.

✅ **Correct — build and push with ko:**
```bash
ko build ./cmd/myservice
ko publish ./cmd/myservice --platform=linux/amd64,linux/arm64
```

❌ **Wrong — using Docker to build Go images:**
```dockerfile
# Do not use Dockerfiles for Go service images
FROM golang:1.22 AS builder
WORKDIR /app
COPY . .
RUN go build -o myservice ./cmd/myservice

FROM debian:bookworm-slim
COPY --from=builder /app/myservice /myservice
ENTRYPOINT ["/myservice"]
```

## Code Quality Verification

### Verification Workflow

After making code changes, run these checks in order:

1. **Build:** `go build -o /dev/null` — verify compilation
2. **Test:** `go test ./...` — ensure tests pass
3. **Format:** `gofmt -s -w .` — apply formatting with simplifications
4. **Lint:** `golangci-lint run` — fix any reported issues

All four must pass before code is considered complete.

### Format String Audit

Use `%q` for quoted strings instead of `'%s'` or `"%s"`. The `%q` verb adds quotes and escapes special characters automatically.

✅ **Correct:**
```go
return fmt.Errorf("unknown field %q", name)
```

❌ **Wrong:**
```go
return fmt.Errorf("unknown field '%s'", name)
return fmt.Errorf("unknown field \"%s\"", name)
```

**Audit:** Search `.go` files for `['"]%s['"]` to find quoted `%s` that should use `%q`.

### API Visibility Audit

Make types, functions, and variables private (lowercase) unless they need to be part of the public API. Only expose what external consumers actually need.

✅ **Correct — only export what external callers need:**
```go
// Client is exported because callers construct and use it.
type Client struct {
    endpoint string
}

// New is exported because callers need to create a Client.
func New(endpoint string) *Client {
    return &Client{endpoint: endpoint}
}

// retry is private — it is an internal implementation detail.
func retry(fn func() error, attempts int) error {
    // ...
}
```

❌ **Wrong — exporting internal implementation details:**
```go
// RetryHelper is exported but only used internally — make it private.
type RetryHelper struct{ attempts int }

// BuildRequestURL is exported but only called within this package.
func BuildRequestURL(base, path string) string {
    return base + path
}
```

**Audit:** Search `.go` files for `^type [A-Z]` and `^func [A-Z]` to find public types and functions. Evaluate whether each needs to be exported.

### Method Receiver Audit

Detach private methods that don't use receiver state and convert them to standalone functions. This improves testability, reduces coupling, and clarifies intent.

✅ **Correct:**
```go
func validateInput(input string) error {
    if input == "" {
        return errors.New("input cannot be empty")
    }
    return nil
}
```

❌ **Wrong:**
```go
func (s *Service) validateInput(input string) error {
    if input == "" {
        return errors.New("input cannot be empty")
    }
    return nil
}
```

**Audit:** Search `.go` files for `^func \(.*\) [a-z]` to find private methods. Check if they actually use the receiver.

## Package Design

Ensure packages have strong test coverage, especially for exported APIs and edge cases.

### Naming: Avoid Stutter

Do not repeat the package name in exported identifiers.

✅ **Correct:**
```go
package future

func New() *Future { ... }  // called as future.New()
```

❌ **Wrong:**
```go
package future

func NewFuture() *Future { ... }  // called as future.NewFuture() — stutters
```

### Prefer Private Types

Keep types, functions, and variables private (lowercase) unless external consumers need them. Expose implementation via interfaces when possible.

✅ **Correct — private concrete type, public interface:**
```go
// Doer is the public interface external callers depend on.
type Doer interface {
    Do(ctx context.Context) error
}

// worker is private; callers receive a Doer, not a *worker.
type worker struct {
    queue chan task
}

func New() Doer { return &worker{queue: make(chan task, 10)} }
```

❌ **Wrong — exporting a concrete type that could be private:**
```go
// Worker is exported but external callers never need the concrete type.
type Worker struct {
    queue chan task
}

func New() *Worker { return &Worker{queue: make(chan task, 10)} }
```

### Thread Safety

Document thread safety guarantees in package documentation. Include concurrent access tests when applicable.

✅ **Correct — documented guarantees and mutex-protected state:**
```go
// Cache is safe for concurrent use by multiple goroutines.
type Cache struct {
    mu    sync.RWMutex
    items map[string]string
}

func (c *Cache) Get(key string) (string, bool) {
    c.mu.RLock()
    defer c.mu.RUnlock()
    v, ok := c.items[key]
    return v, ok
}
```

❌ **Wrong — shared mutable state with no synchronization and no documentation:**
```go
// Cache has no thread-safety documentation and no locking.
type Cache struct {
    items map[string]string // concurrent reads/writes will race
}

func (c *Cache) Get(key string) (string, bool) {
    v, ok := c.items[key]
    return v, ok
}
```

## Package Organization

### Prefer `internal/` Over `pkg/`

Use `internal/` for packages shared within a module that should not be accessible externally. The Go toolchain enforces this restriction at compile time.

Reserve `pkg/` only for packages intended to be imported by external modules. Do not put implementation-only packages in `pkg/`.

✅ **Correct — implementation helpers under `internal/`:**
```
mymodule/
├── cmd/
│   └── server/
│       └── main.go
├── internal/
│   ├── auth/       # shared within module, not exported
│   └── config/     # shared within module, not exported
└── pkg/
    └── api/        # intentionally exported for external consumers
```

❌ **Wrong — implementation helpers under `pkg/` where they are unintentionally importable:**
```
mymodule/
├── cmd/
│   └── server/
│       └── main.go
└── pkg/
    ├── auth/       # should be internal/ — not meant for external use
    └── config/     # should be internal/ — not meant for external use
```

## Testing Standards

- Use table-driven tests with `t.Run` and descriptive sub-test names
- Use the `got`/`want` pattern in error messages: `t.Errorf("field: got = %v, want = %v", got, want)`
- Use `cmp.Diff(want, got)` for complex values — always `(-want, +got)` convention
- Use `t.Context()` instead of `context.Background()` in tests
- Prefer randomly generated values over sentinels like `"test"` when testing value preservation
- Use string operations instead of regex when possible

For detailed examples, see [testing patterns](references/testing-patterns.md).

## General Principles

- **Simple over clever**: Prefer clean, maintainable solutions over concise or performant ones. Readability is primary.
- **Match surrounding style**: When modifying code, match existing file conventions even if they differ from external standards.
- **Evergreen comments**: Never reference temporal context ("recently changed", "new approach"). Describe the code as-is.
- **Evergreen names**: Never name things "improved", "new", "enhanced". What is new today is old tomorrow.
- **Never skip failing tests**: Debug them. Ask for help if needed.
- **Minimal dependencies**: Prefer standard library.
- **No over-engineering**: Only make changes directly requested or clearly necessary. Three similar lines are better than a premature abstraction.
