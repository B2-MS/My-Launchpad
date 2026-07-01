# Packaging Workflow

Build, deploy, and create DMG installer for distribution.

---

## Step 1: Run the Pack Script

```bash
./scripts/pack-it.sh
```

This automatically:
- Builds the app
- Stops any running instances
- Installs to /Applications
- Launches the app
- Verifies the build succeeded
- Creates DMG installer

### Output Files

| File | Location |
|------|----------|
| App Bundle | `build/My Launchpad.app` |
| DMG Installer | `releases/My Launchpad Installer.dmg` |

---

## Step 2: Test the DMG

1. Open `releases/My Launchpad Installer.dmg`
2. Verify the installer window appears correctly
3. Test drag-to-install to Applications

---

## Step 3: Update Documentation

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

## Step 4: Verify Documentation

```bash
./scripts/verify-docs.sh
```

All checks must pass before proceeding to release.
