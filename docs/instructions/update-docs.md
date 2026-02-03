# Documentation Update Instructions

This file contains all prompts and checklists for updating documentation after making changes to My Launchpad.

---

## Markdown Files Checklist

| File | What to Update |
|------|----------------|
| `README.md` | Version badge (e.g., `Version-1.5.5-purple`) |
| `RELEASE_NOTES.md` | Add new version section at top with changes |
| `My Launchpad User Guide.md` | Document any new features or behavior changes |
| `My Launchpad User Guide.md` | **Sync Version History** with RELEASE_NOTES.md |
| `docs/chat-history.md` | **REQUIRED**: Append session summary |
| `docs/prompts-used.md` | **REQUIRED**: Append exact prompts used |

---

## 1. Update Chat History

Copy/paste this prompt to append the session summary:

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

---

## 2. Update Prompts Used

Copy/paste this prompt to append exact prompts:

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

## 3. README.md Version Badge

```markdown
![Version](https://img.shields.io/badge/Version-X.X.X-purple.svg)
```

---

## 4. RELEASE_NOTES.md Template

```markdown
## Version X.X.X (Month Year)

### New Features
- **Feature Name** - Description

### Improvements
- **Improvement Name** - Description

### Bug Fixes
- Fixed issue where...
```

---

## 5. Final Verification

**REQUIRED:** Run the verification script before completing any workflow:

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
