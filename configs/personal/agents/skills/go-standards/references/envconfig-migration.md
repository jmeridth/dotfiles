# Migrating from Kelsey Hightower's envconfig

Code using `github.com/kelseyhightower/envconfig` must be migrated to `github.com/sethvargo/go-envconfig`. These are different libraries with different APIs.

## Import Change

```go
// ❌ Old:
"github.com/kelseyhightower/envconfig"

// ✅ New:
"github.com/sethvargo/go-envconfig"
```

## Struct Tag Change

Replace `envconfig:"NAME"` tags with `env:"NAME"`. The `required:"true"` tag becomes `,required` on the `env` tag. The `default:"value"` tag becomes `,default=value` on the `env` tag.

```go
// ❌ Old (Kelsey):
type Config struct {
    Port    int    `envconfig:"PORT" default:"8080"`
    DBHost  string `envconfig:"DB_HOST" required:"true"`
    DryRun  bool   `envconfig:"DRY_RUN"`
}

// ✅ New (Seth):
type Config struct {
    Port    int    `env:"PORT,default=8080"`
    DBHost  string `env:"DB_HOST,required"`
    DryRun  bool   `env:"DRY_RUN"`
}
```

## Processing Change

Replace `envconfig.Process("", &cfg)` with `envconfig.Process(ctx, &cfg)`. Seth's library requires a `context.Context`. For fatal-on-error patterns, use `envconfig.MustProcess(ctx, &cfg)`.

```go
// ❌ Old (Kelsey):
var cfg Config
if err := envconfig.Process("", &cfg); err != nil {
    log.Fatalf("failed to process envconfig: %v", err)
}

// ✅ New (Seth) — option A: explicit error handling
var cfg Config
if err := envconfig.Process(ctx, &cfg); err != nil {
    clog.FatalContextf(ctx, "failed to process envconfig: %v", err)
}

// ✅ New (Seth) — option B: MustProcess (panics on error, preferred)
envconfig.MustProcess(ctx, &cfg)
```

## go.mod Update

Update `go.mod` — remove `github.com/kelseyhightower/envconfig` and add `github.com/sethvargo/go-envconfig`. Run `go mod tidy` after the migration.
