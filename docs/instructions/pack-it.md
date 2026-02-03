# Pack It

Build, deploy, and create DMG installer.

## Command

```bash
./pack-it.sh
```

## What It Does

1. Runs `./rebuild.sh` (build, stop, remove, install, launch)
2. Runs `./verify-build.sh` (validates build succeeded)
3. Runs `./create-dmg.sh` (creates DMG installer)

## After Packing

1. Update documentation: [update-docs.md](update-docs.md)
2. Verify: `./verify-docs.sh`

## Output Files

| File | Location |
|------|----------|
| App Bundle | `build/My Launchpad.app` |
| DMG Installer | `releases/My Launchpad Installer.dmg` |

## Scripts Used

| Script | Purpose |
|--------|---------|
| `rebuild.sh` | Build, stop old, install new, launch |
| `verify-build.sh` | Validate build succeeded |
| `create-dmg.sh` | Create DMG installer |
| `verify-docs.sh` | Validate documentation updated |
