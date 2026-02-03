# Send It

Complete release workflow: build, package, verify, and push to GitHub.

## Command

```bash
./send-it.sh [version] [message]
```

Example:
```bash
./send-it.sh 1.5.6 "Added new feature"
```

## What It Does

1. Runs `./rebuild.sh` (build, stop, remove, install, launch)
2. Runs `./verify-build.sh` (validates build succeeded)
3. Runs `./create-dmg.sh` (creates DMG installer)
4. Runs `./verify-docs.sh` (validates documentation - **fails if not updated**)
5. Git commit and push

## Before Running

**Documentation must be updated first!**

1. Update docs: [update-docs.md](update-docs.md)
2. Verify: `./verify-docs.sh` (must pass)

## Output

| File | Location |
|------|----------|
| App Bundle | `build/My Launchpad.app` |
| DMG Installer | `releases/My Launchpad Installer.dmg` |
| Git | Committed and pushed |

## Optional: GitHub Release

```bash
gh release create v1.5.6 "releases/My Launchpad Installer.dmg" --title "My Launchpad v1.5.6" --generate-notes
```

## Scripts Used

| Script | Purpose |
|--------|---------|
| `rebuild.sh` | Build, stop old, install new, launch |
| `verify-build.sh` | Validate build succeeded |
| `create-dmg.sh` | Create DMG installer |
| `verify-docs.sh` | Validate documentation updated |
