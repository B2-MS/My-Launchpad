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
| `My Launchpad User Guide.md` | **Sync Version History** with RELEASE_NOTES.md |
| `docs/chat-history.md` | **REQUIRED**: Append session summary (see below) |
| `docs/prompts-used.md` | **REQUIRED**: Append exact prompts used (see below) |

#### Update Chat History (Required)

Use this prompt to append the session summary:

```
Review our entire conversation and APPEND a summary to the file:
docs/chat-history.md

Use this format:

---

## Session: [Descriptive Topic Title]
**Date:** [Date]

### Prompts
1. [First prompt - summarized]
2. [Second prompt - summarized]
...

### Outcomes
- [What was built/changed/fixed]
- [Key files modified]

---

APPEND to the END of the file. Do not overwrite. Ensure chronological order.
```

#### Update Prompts Used (Required)

Use this prompt to append exact prompts:

```
Review our entire conversation and APPEND to the file:
docs/prompts-used.md

Extract EVERY prompt/request I made - use my EXACT words, not summaries.

Format:

---

## Session: [Descriptive Topic Title]
**Date:** [Date]

### Prompt 1: [Brief Title]
```
[Exact text of my prompt]
```

### Prompt 2: [Brief Title]
```
[Exact text of my prompt]
```

... continue for ALL prompts

---

IMPORTANT:
- Use my EXACT words in code blocks
- Include EVERY prompt, even short ones
- APPEND session to the END of the file
- Ensure entries are in CHRONOLOGICAL order
- UPDATE the Summary table at the TOP with the new session count
```

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
- [ ] chat-history.md updated (chronological order)
- [ ] prompts-used.md updated (chronological order, summary updated)
- [ ] **Run `./verify-docs.sh` - ALL CHECKS PASS**
- [ ] App launches and works correctly
- [ ] Changes committed to git
- [ ] Changes pushed to GitHub
- [ ] DMG created
- [ ] GitHub Release published with DMG

---

## Final Step: Verify Documentation

**REQUIRED:** Run the verification script before completing:

```bash
./verify-docs.sh
```

This script checks:
- ✅ README.md version badge
- ✅ RELEASE_NOTES.md version section
- ✅ User Guide version history
- ✅ chat-history.md recent entry
- ✅ prompts-used.md summary matches actual counts

**Do not mark as complete until all checks pass!**

---

## Notes

- The `gh` command requires GitHub CLI (`brew install gh`)
- First time use requires authentication: `gh auth login`
- Use `--generate-notes` to auto-generate release notes from commits
