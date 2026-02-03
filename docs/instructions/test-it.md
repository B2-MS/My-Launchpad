# Test It Instructions

Quick rebuild and redeploy for testing My Launchpad.

## Quick Command

```bash
./build.sh && pkill -f "My Launchpad" 2>/dev/null; rm -rf "/Applications/My Launchpad.app" && cp -R "build/My Launchpad.app" "/Applications/" && open "/Applications/My Launchpad.app"
```

## What It Does

1. 🔨 Rebuilds the app with `./build.sh`
2. 🛑 Stops any running instances
3. 🗑️ Removes the installed version from Applications
4. 📦 Copies the new build to Applications
5. 🚀 Launches the app for testing

---

## After Testing: Update Documentation

After your testing session, update the development history files:

### 1. Update Chat History

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

### 2. Update Prompts Used

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
