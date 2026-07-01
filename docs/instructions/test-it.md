# Testing Workflow

Quick rebuild and deploy for testing during development.

---

## Step 1: Write Test Cases (Before Coding)

Before implementing a feature, define test cases in `docs/test-cases.md`:

```markdown
### TC-XXX: [Test Name]
**Feature:** [Feature being tested]
**Added:** [Version]
**Status:** ⏳ Pending

**Steps:**
1. [Step 1]
2. [Step 2]

**Expected:** [What should happen]
**Actual:** [To be filled after testing]
**Tested:** [Date]
```

---

## Step 2: Run the Test Script

```bash
./scripts/testing-workflow.sh
```

This automatically:
- Builds the app
- Stops any running instances
- Installs to /Applications
- Launches the app
- Verifies the build succeeded

---

## Step 3: Execute Test Cases

Run each test case defined for the current feature:

1. Follow the steps exactly as written
2. Compare actual result to expected result
3. Update the test case in `docs/test-cases.md`:
   - **Status:** ✅ Pass or ❌ Fail
   - **Actual:** What actually happened
   - **Tested:** Current date

### Quick Regression Tests
Also verify core functionality still works:
- [ ] App launches correctly
- [ ] Global hotkey (⌃⌥Space) toggles window
- [ ] Groups display and expand properly
- [ ] Apps launch when clicked
- [ ] Settings persist after restart

---

## Step 4: Update Documentation

Ask Copilot to update the session documentation:

### Chat History
```
Review our entire conversation and APPEND a summary to docs/chat-history.md
```

### Prompts Used
```
Review our entire conversation and APPEND to docs/prompts-used.md
Extract EVERY prompt/request I made - use my EXACT words.
Then UPDATE the Summary section counts at the top of the file.
```

---

## Step 5: Verify Documentation

```bash
./scripts/verify-docs.sh
```

All checks must pass before proceeding to packaging or release.

---

## Test Case Reference

See `docs/test-cases.md` for:
- All existing test cases
- Test summary by version
- Test case template
