# Testing Patterns

Detailed examples for Go testing standards.

## Table-Driven Tests

Use table-driven tests with descriptive sub-test names. Test edge cases: empty inputs, nil values, error conditions, boundary cases.

```go
tests := []struct {
    name    string
    input   string
    want    string
    wantErr bool
}{{
    name:    "empty input",
    input:   "",
    wantErr: true,
}, {
    name:  "valid input",
    input: "hello",
    want:  "HELLO",
}}

for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) {
        got, err := Transform(tt.input)
        if (err != nil) != tt.wantErr {
            t.Fatalf("error: got = %v, wanted error = %v", err, tt.wantErr)
        }
        if got != tt.want {
            t.Errorf("result: got = %q, wanted = %q", got, tt.want)
        }
    })
}
```

## Error Message Format

Use the `got`/`want` pattern consistently. Both `want` and `wanted` are acceptable.

✅ **Correct:**
```go
t.Errorf("field name: got = %v, want = %v", actual, expected)
t.Errorf("count: got = %d, wanted = %d", len(items), expectedCount)
t.Errorf("SHA() = %q, want %q", got, expected)
```

❌ **Wrong:**
```go
t.Errorf("Expected %v, got %v", expected, actual)
t.Error("Should be valid")
```

## Comparing Complex Values with `cmp.Diff`

Use `github.com/google/go-cmp/cmp` for structs, slices, maps. Always use `(-want, +got)`.

```go
if diff := cmp.Diff(want, got); diff != "" {
    t.Errorf("Result mismatch (-want, +got):\n%s", diff)
}
```

❌ **Wrong — args reversed:**
```go
if diff := cmp.Diff(got, want); diff != "" { ... }
```

## Use `t.Context()` in Tests

Use `t.Context()` instead of `context.Background()` or `context.TODO()`. The test context is automatically canceled when the test completes.

```go
func TestFoo(t *testing.T) {
    result, err := DoWork(t.Context())
    ...
}
```

## Random Test Values

Prefer randomly generated values over simple sentinels (like `"test"`, `"result"`) when testing value preservation. This catches bugs hidden by predictable data.

```go
input := fmt.Sprintf("test-%d", rand.Int63())
```

Use sentinels only when the value has semantic meaning (like testing specific error messages).
