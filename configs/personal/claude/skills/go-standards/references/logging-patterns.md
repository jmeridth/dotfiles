# slog Logging Patterns

Extended examples for `log/slog` usage patterns (Go 1.21+).

## Choosing the Right Form

| Situation | Use |
|-----------|-----|
| Single log statement, no structured fields | `slog.InfoContext(ctx, "message")` |
| Structured fields | `slog.InfoContext(ctx, "msg", "key", val)` |
| Format string needed | `slog.InfoContext(ctx, fmt.Sprintf("processing %q", name))` |
| Persistent fields on a sub-logger | `logger := slog.Default().With("key", val)` |

## Basic Context-Aware Logging

Always use the `*Context` variants to propagate context through the call chain:

```go
slog.InfoContext(ctx, "processing items", "count", count)
slog.WarnContext(ctx, "retrying request", "attempt", attempt)
slog.ErrorContext(ctx, "failed to process", "name", name, "error", err)
slog.DebugContext(ctx, "cache hit", "key", key)
```

## Format Strings

`slog` does not have format variants. Use `fmt.Sprintf` when you need formatting:

```go
slog.InfoContext(ctx, fmt.Sprintf("processing %q", name))
slog.ErrorContext(ctx, fmt.Sprintf("unexpected status %d", code))
```

Prefer structured fields over format strings when possible — they are more queryable:

```go
// Prefer this:
slog.InfoContext(ctx, "processing item", "name", name)

// Over this:
slog.InfoContext(ctx, fmt.Sprintf("processing %q", name))
```

## Sub-Logger with Persistent Fields

When you need persistent key-value pairs across multiple log calls, create a sub-logger with `.With()`:

```go
logger := slog.Default().With("request_id", reqID, "user", userID)
logger.InfoContext(ctx, "handling request")   // includes request_id and user
logger.InfoContext(ctx, "request complete")   // includes request_id and user
```

Pass sub-loggers explicitly rather than storing them in package-level state.

## Logging in `main` on Fatal Error

Use `slog.ErrorContext` followed by `os.Exit(1)` — there is no `Fatal` equivalent in `log/slog`:

```go
if err := run(ctx); err != nil {
    slog.ErrorContext(ctx, "run failed", "error", err)
    os.Exit(1)
}
```

## Common Mistakes

❌ **Wrong — using stdlib `log` package for application logging:**
```go
import "log"

log.Printf("processing %d items", count)
```

❌ **Wrong — non-context variant when context is available:**
```go
slog.Info("processing items", "count", count) // loses context
```

✅ **Correct — always pass context:**
```go
slog.InfoContext(ctx, "processing items", "count", count)
```

❌ **Wrong — using `fmt.Println` for logging:**
```go
fmt.Println("starting server")
```

✅ **Correct:**
```go
slog.InfoContext(ctx, "starting server", "addr", addr)
```

## Configuring the Default Logger

In `main`, configure the default logger once at startup. Use `slog.SetDefault` with your chosen handler:

```go
func main() {
    slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
        Level: slog.LevelInfo,
    })))

    ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
    defer cancel()

    if err := run(ctx); err != nil {
        slog.ErrorContext(ctx, "run failed", "error", err)
        os.Exit(1)
    }
}
```

All subsequent `slog.*Context` calls use this handler. Library packages must never call `slog.SetDefault` — only binaries (main packages) may configure the default logger.
