# Test It

Quick rebuild and deploy for testing.

## Command

```bash
./test-it.sh
```

## What It Does

1. Runs `./rebuild.sh` (build, stop, remove, install, launch)
2. Runs `./verify-build.sh` (validates build succeeded)

## After Testing

1. Update documentation: [update-docs.md](update-docs.md)
2. Verify: `./verify-docs.sh`

## Scripts Used

| Script | Purpose |
|--------|---------|
| `rebuild.sh` | Build, stop old, install new, launch |
| `verify-build.sh` | Validate build succeeded |
| `verify-docs.sh` | Validate documentation updated |
