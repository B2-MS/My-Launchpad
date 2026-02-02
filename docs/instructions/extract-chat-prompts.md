# Extract Chat Prompts Instructions

Use this prompt to have each chat session directly append its history to the chat-history.md file.

---

## Prompt to Copy/Paste into Each Chat Session

```
Review our entire conversation and APPEND a summary to the file:
docs/chat-history.md

Use this exact format:

---

## Session: [Descriptive Topic Title]
**Date:** [Date from conversation context]

### Prompts
1. [First prompt I made - summarized in 1-2 sentences]
2. [Second prompt - summarized]
... [continue for all prompts]

### Outcomes
- [What was built/changed/fixed]
- [Key files modified]
- [Important decisions made]

---

IMPORTANT: Append to the END of the existing file. Do not overwrite. Include ALL prompts from this session.
```

---

## Notes

- Each chat session will write directly to `docs/chat-history.md`
- Sessions will append to the end, preserving previous entries
- Run this prompt in each of your 9 chat sessions
