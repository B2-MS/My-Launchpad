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

## Version 1.8.0 Tests

### TC-018: Drag App to Grid - Pin as Standalone
**Feature:** Drag app from Apps section to open grid space
**Added:** v1.8.0
**Status:** ✅ Pass

**Steps:**
1. Open My Launchpad
2. Scroll to the Apps section
3. Drag an app icon upward onto an open area of the grid
4. Release the drag

**Expected:** App is pinned as a standalone tile at the drop position
**Actual:** App appears as standalone tile at the correct grid position
**Tested:** March 3, 2026 by User

### TC-019: Pin Button in Edit Mode
**Feature:** Orange pin icon on apps in edit mode
**Added:** v1.8.0
**Status:** ✅ Pass

**Steps:**
1. Click the edit (pencil) icon in the top-right toolbar
2. Observe app icons in the Apps section
3. Click the orange pin icon on an app

**Expected:** Orange pin button appears on each app; clicking pins it to the grid
**Actual:** Pin button appears and clicking it adds the app as a standalone grid tile
**Tested:** March 3, 2026 by User

### TC-020: Unpin Button in Edit Mode
**Feature:** Orange unpin icon on pinned grid apps in edit mode
**Added:** v1.8.0
**Status:** ✅ Pass

**Steps:**
1. Pin an app to the grid (via drag or pin button)
2. Enter edit mode (pencil icon)
3. Click the orange unpin icon on the pinned app tile

**Expected:** Orange unpin button appears on standalone grid tiles; clicking removes from grid
**Actual:** Unpin button appears and clicking it returns the app to the Apps section
**Tested:** March 3, 2026 by User

### TC-021: Drag Standalone App Between Groups
**Feature:** Reorder a pinned standalone app by dragging between groups
**Added:** v1.8.0
**Status:** ✅ Pass

**Steps:**
1. Pin an app to the grid
2. Drag the standalone app tile to a gap between two group tiles
3. Release the drag

**Expected:** App tile moves to the new position between the groups
**Actual:** App repositions correctly between groups and grid repaginates
**Tested:** March 3, 2026 by User

### TC-022: Drop Position Accuracy
**Feature:** Row-aware drop positioning
**Added:** v1.8.0
**Status:** ✅ Pass

**Steps:**
1. Have multiple rows of groups on the grid
2. Drag an app from the Apps section to a specific position on row 2
3. Release the drag

**Expected:** App appears at the position on row 2, not defaulting to row 1
**Actual:** App placed at the correct row and column position
**Tested:** March 3, 2026 by User

---

## Version 1.7.0 Tests

### TC-013: Resize Group to Large
**Feature:** Right-click → Resize Group → Large (2×1)
**Added:** v1.7.0
**Status:** ✅ Pass

**Steps:**
1. Right-click on a Standard (1×1) group
2. Select "Resize Group" → "Large"
3. Observe the group tile size changes

**Expected:** Group becomes a double-wide tile showing 4×2 grid (8 app icons)
**Actual:** Group resizes to Large correctly
**Tested:** March 2, 2026

---

### TC-014: Resize Group to Extra Large
**Feature:** Right-click → Resize Group → Extra Large (2×2)
**Added:** v1.7.0
**Status:** ✅ Pass

**Steps:**
1. Right-click on a group
2. Select "Resize Group" → "Extra Large"
3. Observe the group tile size changes

**Expected:** Group becomes a double-wide, double-tall tile showing 4×4 grid (16 app icons)
**Actual:** Group resizes to Extra Large correctly
**Tested:** March 2, 2026

---

### TC-015: Drag and Drop - Swap Groups
**Feature:** Drag group onto another group to swap positions
**Added:** v1.7.0
**Status:** ✅ Pass

**Steps:**
1. Drag a group tile and drop it directly onto another group
2. Observe the positions

**Expected:** The two groups swap positions, with smooth animation
**Actual:** Groups swap correctly with animation
**Tested:** March 2, 2026

---

### TC-016: Drag and Drop - Insert Between Groups
**Feature:** Drag group to gap between groups to insert
**Added:** v1.7.0
**Status:** ✅ Pass

**Steps:**
1. Drag a group tile
2. Drop it in the gap between two other groups (not directly on a group)
3. Observe the positions

**Expected:** The dragged group is inserted at the drop position, pushing others over
**Actual:** Insert between works correctly
**Tested:** March 2, 2026

---

### TC-017: Mixed Size Group Grid Layout
**Feature:** Bin-packing layout with mixed tile sizes
**Added:** v1.7.0
**Status:** ✅ Pass

**Steps:**
1. Resize some groups to Standard, some to Large, some to Extra Large
2. Observe the grid layout arranges them efficiently

**Expected:** Tiles pack efficiently with no overlapping, smaller tiles fill gaps
**Actual:** Bin-packing layout works correctly
**Tested:** March 2, 2026

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

## Version 1.6.1 Tests

### TC-012: Window Moves to Current Desktop
**Feature:** Multi-desktop support
**Added:** v1.6.1
**Status:** ✅ Pass

**Steps:**
1. Open My Launchpad on Desktop 1
2. Switch to Desktop 2 (swipe or Control+Arrow)
3. Press Control+Option+Space to show app
4. Observe which desktop the window appears on

**Expected:** Window appears on Desktop 2 (current desktop)
**Actual:** Window moves to current desktop correctly
**Tested:** February 25, 2026

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
| v1.7.0 | 5 | 5 | 0 |
| v1.6.1 | 1 | 1 | 0 |
| v1.6.0 | 3 | 3 | 0 |
| v1.5.9 | 2 | 2 | 0 |
| v1.5.8 | 2 | 2 | 0 |
| v1.5.7 | 1 | 1 | 0 |
| Core | 3 | 3 | 0 |
| **Total** | **17** | **17** | **0** |

---

## Adding New Test Cases

When implementing a new feature:

1. **Before coding:** Define test cases for the feature
2. **After coding:** Run the test cases
3. **Document results:** Update this file with test status
4. **On release:** Verify all tests pass before "send it"
