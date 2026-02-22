# Release Workflow

Complete release: build, package, verify documentation, and push to GitHub.

---

## Step 1: Update Version Files

Before releasing, update version numbers in:

| File | What to Update |
|------|----------------|
| `README.md` | Version badge: `Version-X.X.X-purple` |
| `RELEASE_NOTES.md` | Add new version section at top |
| `My Launchpad User Guide.md` | Add to Version History section |
| `Resources/Info.plist` | `CFBundleShortVersionString` |

---

## Step 2: Update Session Documentation

Ask Copilot to update the session documentation:

### Chat History
```
Review our entire conversation and APPEND a summary to docs/chat-history.md

Use this format:
---
## Session: [Descriptive Topic Title]
**Date:** [Date]

### Prompts
1. [First prompt - summarized]
2. [Second prompt - summarized]

### Outcomes
- [What was built/changed/fixed]
- [Key files modified]
---

APPEND to the END of the file. Do not overwrite.
```

### Prompts Used
```
Review our entire conversation and APPEND to docs/prompts-used.md

Extract EVERY prompt/request I made - use my EXACT words, not summaries.

Format:
## Session: [Date] - [Topic] (vX.X.X)
1. "[exact prompt 1]"
2. "[exact prompt 2]"

Then UPDATE the Summary section counts at the top of the file.
```

---

## Step 3: Verify Documentation First

```bash
./scripts/verify-docs.sh
```

⚠️ **All checks must pass before running send-it.sh** - the script will fail if documentation is not updated.

---

## Step 4: Run the Release Script

```bash
./scripts/send-it.sh [version] [message]
```

Example:
```bash
./scripts/send-it.sh 1.5.6 "Reorganize scripts into scripts folder"
```

This automatically:
- Builds the app
- Verifies the build
- Creates DMG installer
- Verifies documentation (fails if not updated)
- Git commit and push

---

## Step 5: Optional GitHub Release

Create a formal GitHub release with the DMG attached:

```bash
gh release create v1.5.6 "releases/My Launchpad Installer.dmg" --title "My Launchpad v1.5.6" --generate-notes
```

---

## Output Files

| File | Location |
|------|----------|
| App Bundle | `build/My Launchpad.app` |
| DMG Installer | `releases/My Launchpad Installer.dmg` |
| Git | Committed and pushed to GitHub |
