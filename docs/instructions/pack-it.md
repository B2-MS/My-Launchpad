# Pack It Instructions

Build, package, and prepare My Launchpad for distribution.

---

## Scripts Overview

| Script | Purpose |
|--------|---------|
| `rebuild.sh` | Build, stop, remove, install, launch |
| `build.sh` | Full build with app bundle creation |
| `deploy.sh` | Quick rebuild and launch (development) |
| `create-dmg.sh` | Create distributable DMG installer |
| `verify-docs.sh` | Verify all documentation is updated |

---

## Workflow

### 1. Rebuild & Deploy

```bash
./rebuild.sh
```

### 2. Update Documentation

📝 See [update-docs.md](update-docs.md) for all prompts and checklists.

### 3. Create DMG (Optional)

```bash
./create-dmg.sh
```

### 4. Verify Documentation

```bash
./verify-docs.sh
```

**Do not mark as complete until all checks pass!**

---

## Output Files

| File | Location |
|------|----------|
| App Bundle | `build/My Launchpad.app` |
| DMG Installer | `releases/My Launchpad Installer.dmg` |

---

## Troubleshooting

### Build fails - executable not found
- Ensure Swift is installed: `swift --version`
- Check for compilation errors in the output

### Code signing warnings
- Ad-hoc signing (`--sign -`) is used for local testing
- For distribution, use a valid Developer ID certificate

### DMG creation fails
- Ensure the app bundle exists (run `build.sh` first)
- Check for mounted volumes with the same name
