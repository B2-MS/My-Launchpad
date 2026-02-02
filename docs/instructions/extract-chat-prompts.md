# Extract Chat Prompts Instructions

Use these prompts to extract information from each chat session.

---

## Prompt 1: Extract Actual Prompts (Copy to prompts-used.md)

Copy/paste this into each chat session to extract your exact prompts:

```
Review our entire conversation and APPEND to the file:
docs/prompts-used.md

Extract EVERY prompt/request I made - use my EXACT words, not summaries.

Format:

---

## Session: [Descriptive Topic Title]
**Date:** [Date from context]

### Prompts

1. "[Exact text of my first prompt]"

2. "[Exact text of my second prompt]"

3. "[Exact text of my third prompt]"

... continue for ALL prompts

---

IMPORTANT:
- Use my EXACT words in quotes
- Include EVERY prompt, even short ones like "yes", "pack it", "test it"
- APPEND to the END of the file
- Do not overwrite existing content
```

---

## Prompt 2: Update Chat History Summary (Copy to chat-history.md)

Use this prompt to append a session summary:

```
Review our entire conversation and APPEND a summary to the file:
docs/chat-history.md

Use this format:

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

- Run Prompt 1 first to capture exact wording
- Run Prompt 2 to add summarized history
- Each session should be documented in both files
