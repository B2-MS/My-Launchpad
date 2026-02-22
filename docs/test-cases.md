# My Launchpad Test Cases

This file documents test cases for each feature. Tests are written when features are implemented and executed before release.

---

## Test Case Format

```markdown
### TC-XXX: [Test Name]
**Feature:** [Feature being tested]
**Added:** [Version]
**Status:** ✅ Pass | ❌ Fail | ⏳ Pending

**Steps:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected:** [What should happen]
**Actual:** [What actually happened]
**Tested:** [Date] by [Tester]
```

---

## Core Functionality Tests

### TC-001: App Launch
**Feature:** Basic app launch
**Added:** v1.0.0
**Status:** ✅ Pass

**Steps:**
1. Open My Launchpad from /Applications
2. Observe the main window

**Expected:** App launches with main window showing groups and apps
**Actual:** App launches correctly
**Tested:** February 22, 2026

---

### TC-002: Global Hotkey
**Feature:** Control+Option+Space toggle
**Added:** v1.0.0
**Status:** ✅ Pass

**Steps:**
1. Hide the app window
2. Press Control+Option+Space
3. Press Control+Option+Space again

**Expected:** Window shows on first press, hides on second
**Actual:** Hotkey toggles window visibility correctly
**Tested:** February 22, 2026

---

### TC-003: Menu Bar Icon
**Feature:** Menu bar presence
**Added:** v1.0.0
**Status:** ✅ Pass

**Steps:**
1. Launch app
2. Look in menu bar
3. Click icon
4. Right-click icon

**Expected:** Icon appears in menu bar, click toggles window, right-click shows menu
**Actual:** Menu bar icon works correctly
**Tested:** February 22, 2026

---

## Version 1.6.0 Tests

### TC-004: Launch at Login Toggle
**Feature:** Settings > Launch at Login
**Added:** v1.6.0
**Status:** ✅ Pass

**Steps:**
1. Open app
2. Click gear icon to open Settings
3. Check "Launch at login" checkbox
4. Log out and log back in (or restart)

**Expected:** App starts automatically after login, appears in menu bar
**Actual:** Launch at login works correctly using SMAppService
**Tested:** February 22, 2026

---

### TC-005: Settings Auto-Close on Hide
**Feature:** Settings panel closes when app hidden
**Added:** v1.6.0
**Status:** ✅ Pass

**Steps:**
1. Open app
2. Click gear icon to open Settings
3. Press Control+Option+Space to hide app
4. Press Control+Option+Space to show app

**Expected:** Settings panel should be closed when app reappears
**Actual:** Settings closes correctly on hide
**Tested:** February 22, 2026

---

### TC-006: Group Popup Auto-Close on Hide
**Feature:** Group popups close when app hidden
**Added:** v1.6.0
**Status:** ✅ Pass

**Steps:**
1. Open app
2. Click on a group to expand it
3. Press Control+Option+Space to hide app
4. Press Control+Option+Space to show app

**Expected:** Group popup should be closed when app reappears
**Actual:** Group popup closes correctly on hide
**Tested:** February 22, 2026

---

## Version 1.5.9 Tests

### TC-007: Search Auto-Clear on App Launch
**Feature:** Search clears when launching app
**Added:** v1.5.9
**Status:** ✅ Pass

**Steps:**
1. Open app
2. Type in search field
3. Click on an app to launch it
4. Reopen My Launchpad

**Expected:** Search field should be empty
**Actual:** Search text clears after app launch
**Tested:** February 18, 2026

---

### TC-008: Search X Button
**Feature:** Clear button in search field
**Added:** v1.5.9
**Status:** ✅ Pass

**Steps:**
1. Open app
2. Type in search field
3. Click the X button

**Expected:** Search field clears, X button disappears
**Actual:** X button clears search correctly
**Tested:** February 18, 2026

---

## Version 1.5.8 Tests

### TC-009: iCloud Backup Toggle
**Feature:** Cloud backup to iCloud
**Added:** v1.5.8
**Status:** ✅ Pass

**Steps:**
1. Open Settings
2. Enable "iCloud Drive" under Cloud Backup
3. Make a change (create a group)
4. Check ~/Library/Mobile Documents/com~apple~CloudDocs/My Launchpad/

**Expected:** Backup file appears in iCloud folder
**Actual:** Backup syncs to iCloud
**Tested:** February 4, 2026

---

### TC-010: OneDrive Backup Toggle
**Feature:** Cloud backup to OneDrive
**Added:** v1.5.8
**Status:** ✅ Pass

**Steps:**
1. Open Settings
2. Enable "OneDrive" under Cloud Backup
3. Make a change (create a group)
4. Check ~/Library/CloudStorage/OneDrive-Personal/My Launchpad/

**Expected:** Backup file appears in OneDrive folder
**Actual:** Backup syncs to OneDrive
**Tested:** February 4, 2026

---

## Version 1.5.7 Tests

### TC-011: Auto-Detect New Apps
**Feature:** New apps appear without restart
**Added:** v1.5.7
**Status:** ✅ Pass

**Steps:**
1. Open My Launchpad
2. Download and install a new app to /Applications
3. Wait 2-3 seconds

**Expected:** New app appears in Apps section automatically
**Actual:** Apps section updates automatically
**Tested:** February 4, 2026

---

## Test Summary

| Version | Tests | Passed | Failed |
|---------|-------|--------|--------|
| v1.6.0 | 3 | 3 | 0 |
| v1.5.9 | 2 | 2 | 0 |
| v1.5.8 | 2 | 2 | 0 |
| v1.5.7 | 1 | 1 | 0 |
| Core | 3 | 3 | 0 |
| **Total** | **11** | **11** | **0** |

---

## Adding New Test Cases

When implementing a new feature:

1. **Before coding:** Define test cases for the feature
2. **After coding:** Run the test cases
3. **Document results:** Update this file with test status
4. **On release:** Verify all tests pass before "send it"
