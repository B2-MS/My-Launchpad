# Pack It Up Now Instructions

Complete workflow for building, deploying, documenting, and publishing My Launchpad.

## Quick Reference

```bash
# Full workflow (steps 1-4, 6)
./build.sh && pkill -f "My Launchpad" 2>/dev/null; rm -rf "/Applications/My Launchpad.app" && cp -R "build/My Launchpad.app" "/Applications/" && open "/Applications/My Launchpad.app"

# After updating markdown files, push to GitHub (step 7)
git add -A && git commit -m "Release v1.x.x - description" && git push
```

---

## Step-by-Step Workflow

### 1. 🔨 Rebuild the App

```bash
./build.sh
```

### 2. 🛑 Remove All Running Instances

```bash
pkill -f "My Launchpad" 2>/dev/null
```

### 3. 🗑️ Remove Installed Version from Applications

```bash
rm -rf "/Applications/My Launchpad.app"
```

### 4. 📦 Install New Version to Applications

```bash
cp -R "build/My Launchpad.app" "/Applications/"
```

### 5. 📝 Update ALL Markdown Files

| File | What to Update |
|------|----------------|
| `README.md` | Version badge (e.g., `Version-1.5.2-purple`) |
| `RELEASE_NOTES.md` | Add new version section at top with all changes |
| `My Launchpad User Guide.md` | Document any new features or behavior changes |

#### README.md Version Badge
```markdown
![Version](https://img.shields.io/badge/Version-X.X.X-purple.svg)
```

#### RELEASE_NOTES.md Template
```markdown
## Version X.X.X (Month Year)

### New Features
- **Feature Name** - Description

### Improvements
- **Improvement Name** - Description

### Bug Fixes
- Fixed issue where...
```

### 6. 🚀 Run the New Version

```bash
open "/Applications/My Launchpad.app"
```

### 7. 📤 Update GitHub Repo

```bash
# Stage all changes
git add -A

# Review what will be committed
git status

# Commit with version message
git commit -m "Release v1.x.x - brief description of changes"

# Push to GitHub
git push
```

### 8. 💿 Create DMG Installer

```bash
./create-dmg.sh
```

### 9. 🚀 Create GitHub Release with DMG

```bash
gh release create vX.X.X "releases/My Launchpad Installer.dmg" --title "My Launchpad vX.X.X" --notes "Release notes here"
```

Or use the full command with formatted notes:
```bash
gh release create vX.X.X "releases/My Launchpad Installer.dmg" \
  --title "My Launchpad vX.X.X" \
  --notes "## What's New

- Feature 1
- Feature 2

**Download:** Open the DMG and drag the app to Applications."
```

---

## Complete One-Liner (Steps 1-4, 6)

```bash
./build.sh && pkill -f "My Launchpad" 2>/dev/null; rm -rf "/Applications/My Launchpad.app" && cp -R "build/My Launchpad.app" "/Applications/" && open "/Applications/My Launchpad.app"
```

## Git Push One-Liner (Step 7)

```bash
git add -A && git commit -m "Release vX.X.X - description" && git push
```

## Full Release One-Liner (Steps 7-9)

```bash
git add -A && git commit -m "Release vX.X.X - description" && git push && ./create-dmg.sh && gh release create vX.X.X "releases/My Launchpad Installer.dmg" --title "My Launchpad vX.X.X" --generate-notes
```

---

## Checklist

- [ ] App builds successfully
- [ ] Old instances stopped
- [ ] Old app removed from /Applications
- [ ] New app installed to /Applications
- [ ] README.md version updated
- [ ] RELEASE_NOTES.md updated with new version
- [ ] User Guide updated (if needed)
- [ ] App launches and works correctly
- [ ] Changes committed to git
- [ ] Changes pushed to GitHub
- [ ] DMG created
- [ ] GitHub Release published with DMG

---

## Notes

- The `gh` command requires GitHub CLI (`brew install gh`)
- First time use requires authentication: `gh auth login`
- Use `--generate-notes` to auto-generate release notes from commits
