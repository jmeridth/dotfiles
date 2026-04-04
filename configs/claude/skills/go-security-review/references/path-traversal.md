# Path Traversal (CWE-22)

Attackers supply crafted path components (e.g., `../../etc/passwd`) to escape an intended base directory and read, write, or delete arbitrary files.

## Dangerous Patterns

### 1. Direct Concatenation

Joining user input directly into a file path with no validation.

**Vulnerable:**
```go
func handler(w http.ResponseWriter, r *http.Request) {
    filename := r.URL.Query().Get("file")
    data, err := os.ReadFile(filepath.Join("/srv/uploads", filename))
    if err != nil {
        http.Error(w, "not found", http.StatusNotFound)
        return
    }
    w.Write(data)
}
```

**Why:** `filename` can be `../../etc/shadow`, causing `filepath.Join` to resolve to `/etc/shadow`.

### 2. filepath.Clean Without Prefix Check

Cleaning the path but not verifying the result stays within the base directory.

**Vulnerable:**
```go
func serve(baseDir, userPath string) ([]byte, error) {
    cleaned := filepath.Clean(userPath)
    fullPath := filepath.Join(baseDir, cleaned)
    return os.ReadFile(fullPath)
}
```

**Why:** `filepath.Clean("../../etc/passwd")` returns `../../etc/passwd`. Joining with `baseDir` still escapes. `filepath.Clean` removes redundant separators and `.` but does NOT prevent traversal.

### 3. String-Based Prefix Check on Uncleaned Path

Checking the prefix before cleaning, which can be bypassed.

**Vulnerable:**
```go
func serve(baseDir, userPath string) ([]byte, error) {
    fullPath := filepath.Join(baseDir, userPath)
    if !strings.HasPrefix(fullPath, baseDir) {
        return nil, fmt.Errorf("access denied")
    }
    return os.ReadFile(fullPath)
}
```

**Why:** `filepath.Join("/srv/data", "../data-secret/file")` produces `/srv/data-secret/file`, which passes the `HasPrefix("/srv/data")` check. The prefix check matches a sibling directory.

### 4. http.ServeFile / http.FileServer With User Input

Using `http.ServeFile` with an unvalidated path.

**Vulnerable:**
```go
func handler(w http.ResponseWriter, r *http.Request) {
    page := r.URL.Query().Get("page")
    http.ServeFile(w, r, filepath.Join("static", page))
}
```

**Why:** `page` can be `../../../etc/passwd`. `http.ServeFile` follows the resolved path.

### 5. Archive Extraction (Zip Slip)

Extracting archive entries without validating the destination path.

**Vulnerable:**
```go
for _, f := range zipReader.File {
    destPath := filepath.Join(extractDir, f.Name)
    // f.Name can be "../../../etc/cron.d/backdoor"
    outFile, _ := os.Create(destPath)
    rc, _ := f.Open()
    io.Copy(outFile, rc)
}
```

**Why:** Archive entry names can contain `../` sequences. This is CVE-2018-1002200 (Zip Slip).

## Safe Patterns

### The Correct Fix: Clean + Resolve + Prefix Verify

The only reliable defense is: resolve both paths to absolute, then verify the prefix.

**Safe:**
```go
func safePath(baseDir, userPath string) (string, error) {
    // Join and clean the path
    fullPath := filepath.Join(baseDir, filepath.Clean("/"+userPath))

    // Resolve to absolute to eliminate all symlinks and relative components
    absBase, err := filepath.Abs(baseDir)
    if err != nil {
        return "", fmt.Errorf("resolve base: %w", err)
    }
    absPath, err := filepath.Abs(fullPath)
    if err != nil {
        return "", fmt.Errorf("resolve path: %w", err)
    }

    // Verify the resolved path is within the base directory
    // Use separator suffix to prevent /srv/data matching /srv/data-secret
    if !strings.HasPrefix(absPath, absBase+string(filepath.Separator)) && absPath != absBase {
        return "", fmt.Errorf("path traversal blocked: %q escapes %q", userPath, baseDir)
    }

    return absPath, nil
}
```

**Key details:**
- `filepath.Clean("/"+userPath)` — prepend `/` to force the cleaned path to be absolute-like, preventing leading `..`
- `filepath.Abs()` on both paths — resolves symlinks and normalizes
- Append `filepath.Separator` to `absBase` before prefix check — prevents `/srv/data` matching `/srv/data-secret`
- Check `absPath != absBase` to allow accessing the base directory itself

### Safe Archive Extraction

**Safe:**
```go
for _, f := range zipReader.File {
    destPath := filepath.Join(extractDir, f.Name)

    // Resolve and verify the destination stays within extractDir
    absExtractDir, _ := filepath.Abs(extractDir)
    absDestPath, _ := filepath.Abs(destPath)

    if !strings.HasPrefix(absDestPath, absExtractDir+string(filepath.Separator)) {
        return fmt.Errorf("zip slip blocked: %q escapes extract directory", f.Name)
    }

    outFile, _ := os.Create(destPath)
    rc, _ := f.Open()
    io.Copy(outFile, rc)
}
```

### Using http.Dir (Built-In Protection)

`http.Dir` combined with `http.FileServer` provides built-in traversal protection.

**Safe:**
```go
fs := http.FileServer(http.Dir("/srv/static"))
http.Handle("/static/", http.StripPrefix("/static/", fs))
```

**Why:** `http.Dir.Open()` rejects paths containing `..` elements. However, this only works when using the `http.FileServer` handler — calling `http.ServeFile` directly bypasses this protection.

## Detection Checklist

When reviewing Go code for path traversal, check each item:

1. **Find file operation sinks**: `os.Open`, `os.ReadFile`, `os.Create`, `os.WriteFile`, `os.Remove`, `os.MkdirAll`, `os.Stat`, `http.ServeFile`, `io.Copy` to file, `os.Rename`, `os.Symlink`
2. **Trace the path argument back**: Does any component originate from user input (HTTP params, headers, form data, uploaded filenames, archive entry names, CLI args)?
3. **Verify sanitization**: Is there a `filepath.Abs` + `strings.HasPrefix(absPath, absBase+sep)` check between the input and the sink?
4. **Check for bypass vectors**:
   - Symlinks: Does the validated path cross a symlink that points outside the base?
   - Race conditions (TOCTOU): Is the path validated then used in a separate operation?
   - Encoding: Is the input URL-decoded after validation? (`%2e%2e%2f` = `../`)

## Regression Test Templates

### Basic Path Traversal Test

```go
// SECURITY FINDING: Path Traversal in `serveFile` {
//   CWE: CWE-22
//   Description: User-controlled path argument flows into os.ReadFile via filepath.Join without validation, allowing directory escape.
//   Risk: HIGH
//   Confidence: 9
//   Attacker: Unauthenticated user
//   Entry: serveFile(baseDir, userInput)
//   Flow: userInput → filepath.Join(baseDir, userInput) → os.ReadFile
//   Exploit: Passing "../../etc/passwd" reads files outside the base directory.
//   Impact: Arbitrary file read from server filesystem.
// }
func TestVuln_CWE22_PathTraversal(t *testing.T) {
    baseDir := t.TempDir()
    os.WriteFile(filepath.Join(baseDir, "allowed.txt"), []byte("ok"), 0644)

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

func TestSafe_CWE22_LegitimateAccess(t *testing.T) {
    baseDir := t.TempDir()
    content := []byte("hello")
    os.WriteFile(filepath.Join(baseDir, "readme.txt"), content, 0644)

    got, err := serveFile(baseDir, "readme.txt")
    if err != nil {
        t.Fatalf("legitimate access blocked: %v", err)
    }
    if !bytes.Equal(got, content) {
        t.Errorf("got %q, want %q", got, content)
    }
}
```

### Zip Slip Test

```go
// SECURITY FINDING: Zip Slip in `extractArchive` {
//   CWE: CWE-22
//   Description: Archive entry names (zip.File.Name) flow into os.Create via filepath.Join without path validation, allowing writes outside the extract directory.
//   Risk: HIGH
//   Confidence: 9
//   Attacker: Any user who can supply an archive for extraction
//   Entry: extractArchive(zipReader, extractDir)
//   Flow: zip.File.Name → filepath.Join(extractDir, f.Name) → os.Create
//   Exploit: A zip entry named "../../etc/cron.d/backdoor" writes outside the extract directory.
//   Impact: Arbitrary file write on server filesystem (CVE-2018-1002200).
// }
func TestVuln_CWE22_ZipSlip(t *testing.T) {
    buf := new(bytes.Buffer)
    zw := zip.NewWriter(buf)
    f, _ := zw.Create("../../etc/cron.d/backdoor")
    f.Write([]byte("malicious content"))
    zw.Close()

    extractDir := t.TempDir()
    zr, _ := zip.NewReader(bytes.NewReader(buf.Bytes()), int64(buf.Len()))

    err := extractArchive(zr, extractDir)
    if err == nil {
        outsidePath := filepath.Join(extractDir, "../../etc/cron.d/backdoor")
        if _, statErr := os.Stat(outsidePath); statErr == nil {
            t.Error("zip slip not blocked: file written outside extract directory")
        }
    }
}
```

### http.ServeFile Test

```go
// SECURITY FINDING: Path Traversal in `handler` via http.ServeFile {
//   CWE: CWE-22
//   Description: User-controlled query parameter flows into http.ServeFile via filepath.Join without path validation.
//   Risk: HIGH
//   Confidence: 9
//   Attacker: Unauthenticated user
//   Entry: GET /download?file=<payload>
//   Flow: r.URL.Query().Get("file") → filepath.Join("static", file) → http.ServeFile
//   Exploit: GET /download?file=../../../etc/passwd reads arbitrary server files.
//   Impact: Arbitrary file read from server filesystem.
// }
func TestVuln_CWE22_ServeFileTraversal(t *testing.T) {
    srv := httptest.NewServer(http.HandlerFunc(handler))
    defer srv.Close()

    resp, err := http.Get(srv.URL + "?file=../../../etc/passwd")
    if err != nil {
        t.Fatal(err)
    }
    defer resp.Body.Close()

    if resp.StatusCode == http.StatusOK {
        body, _ := io.ReadAll(resp.Body)
        if strings.Contains(string(body), "root:") {
            t.Error("path traversal succeeded: /etc/passwd contents returned")
        }
    }
}
```
