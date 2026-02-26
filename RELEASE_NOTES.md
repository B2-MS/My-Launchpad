# Release Notes

## Version 1.6.1 (February 2026)

### Bug Fixes

#### Multi-Desktop Support
- **Window Follows Desktop** - App now appears on your current desktop/space instead of switching you to the desktop where it was originally opened
- Changed window behavior from "join all spaces" to "move to active space"

---

## Version 1.6.0 (February 2026)

### New Features

#### Launch at Login
- **Auto-Start** - New setting to automatically start My Launchpad when you log in
- **Menu Bar Ready** - App appears in menu bar immediately after login
- Uses macOS native SMAppService for reliable startup

#### UI Improvements
- **Settings Auto-Close** - Settings panel closes when app is hidden or loses focus
- **Group Popup Auto-Close** - Open group popups close when app is hidden
- **Clean State on Return** - App always returns to a clean state (no lingering panels)

### Project Structure
- Reorganized documentation into `docs/` folder
- Archived 7 unused instruction files
- Moved `create_icon.swift` to `scripts/`
- Updated all image paths for new structure

---

## Version 1.5.9 (February 2026)

### Improvements

#### Search Enhancements
- **Auto-Clear on Launch** - Search text automatically clears when you open an app
- **Auto-Clear on Hide** - Search clears when the launcher window is hidden or loses focus
- **Clear Button** - Added X button in search field to quickly clear search text

#### DMG Installer
- **Larger Window** - Installer window enlarged to properly display icons without scroll bars
- **Better Icon Positioning** - App and Applications folder icons better centered

---

## Version 1.5.8 (February 2026)

### New Features

#### Cloud Backup
- **iCloud Backup** - Automatically sync your settings to iCloud Drive
- **OneDrive Backup** - Automatically sync your settings to OneDrive
- **Auto-Discovery** - On launch, detects cloud backups from other Macs
- **Import Prompt** - When a different configuration is found in the cloud, prompts to import or keep local settings
- **Cross-Mac Sync** - Easily transfer your app organization between multiple Macs

### How It Works
1. Enable iCloud and/or OneDrive backup in Settings
2. Your settings automatically sync whenever you make changes
3. On another Mac, open My Launchpad (with same cloud account)
4. If cloud settings differ, you'll be prompted to import them

---

## Version 1.5.7 (February 2026)

### New Features

#### Automatic App Detection
- **Live App Monitoring** - New apps added to Applications folder appear automatically without restarting
- **Removed Apps Cleanup** - Apps that are deleted are automatically removed from the launcher
- **Folder Watching** - Monitors `/Applications`, `/System/Applications`, and `~/Applications`
- **Smart Debouncing** - Changes are batched to avoid excessive refreshes during bulk operations

#### Release Workflow
- **Automated GitHub Releases** - `release-workflow.sh` now automatically creates GitHub Releases with DMG attached

---

## Version 1.5.6 (February 2026)

### Project Structure Improvements

#### Scripts Reorganization
- **Scripts Folder** - All 10 shell scripts moved from root to `scripts/` folder
- **Cleaner Root** - Project root now only contains essential config files

#### Workflow Documentation
- **Renamed Instruction Files** - Simple names for triggers: `test-it.md`, `pack-it.md`, `send-it.md`
- **Renamed Scripts** - Descriptive names: `testing-workflow.sh`, `packaging-workflow.sh`, `release-workflow.sh`
- **Integrated Documentation Steps** - Each workflow file now includes prompts for updating chat-history and prompts-used
- **Removed Redundant File** - Merged `update-docs.md` content into workflow files

---

## Version 1.5.5 (February 2026)

### New Features

#### Enhanced Window Transparency
- **Transparent Background** - Window now has a beautiful see-through background (75% opacity)
- **Removed Opaque Materials** - Replaced heavy frosted glass with light color tints
- **Better Desktop Integration** - See your wallpaper and windows through the launcher

#### UI Improvements
- **Removed Groups Dropdown** - Cleaner interface without the redundant dropdown
- **Larger Groups** - Group tiles are now 30% larger for better visibility
- **16 Icons Per Group** - Expanded from 9 to 16 app icons per group
- **Compact Group Header** - Group popup header reduced by 30% for more app space
- **Alphabetical Group Sorting** - "Add to Group" context menu now sorted alphabetically
- **Collapsible Apps Section** - Apps section in settings now collapsible (default: collapsed)

---

## Version 1.5.4 (January 2026)

### New Features

#### Multi-Select Group Operations
- **Add Multiple Apps to Group** - Select multiple apps and right-click to add them all to an existing group at once
- **Create Group with Multiple Apps** - Select multiple apps and right-click to create a new group containing all selected apps
- **Visual Feedback** - New group dialog shows count of selected apps when creating groups with multi-select

#### Edit Mode Improvements
- **Auto-Expand Apps Section** - Clicking the edit icon now automatically expands the Apps section and scrolls to show it
- **Auto-Collapse on Exit** - Exiting edit mode automatically collapses the Apps section

#### Settings Enhancements
- **Real-Time Color Preview** - Groups stay open when adjusting settings so you can preview color changes
- **Click to Close Color Picker** - Clicking outside the color picker now closes it automatically

#### Create Group Dialog
- **Enter Key Support** - Press Enter to create a group after typing the name (no need to click "Create")

---

## Version 1.5.3 (January 2026)

### Improvements

#### Window Positioning & Sizing
- **True Center Positioning** - Window now opens centered in the visible screen area, properly accounting for the menu bar and dock
- **Persistent Window Size** - Window size is remembered between sessions and restored on launch
- **Smart Initial Sizing** - On first launch, window size is calculated based on the number of groups to show them all

---

## Version 1.5.2 (January 2026)

### Improvements

#### Smarter Panel Interactions
- **Click Outside to Close Group** - Clicking anywhere outside an open group popup now closes it
- **Settings Closes Group** - Clicking the settings gear while a group is open automatically closes the group first
- **Group Closes Settings** - Clicking on a group while settings is open automatically closes the settings panel

These changes provide a more intuitive experience where only one panel (group or settings) is open at a time.

---

## Version 1.5.1 (January 2026)

### New Features

#### Multi-Desktop Support
- **Available on All Spaces** - The launcher now appears on your current desktop instead of switching you to another space
- Works with menu bar icon clicks and the global hotkey (⌃⌥Space)
- No more disruptive desktop switching when using multiple spaces

---

## Version 1.5.0 (January 2026)

### New Features

#### Liquid Glass Design
- **Frosted Glass Materials** - Thick vibrancy materials throughout the UI that blur the background beautifully
- **Color-Tinted Panels** - Settings, group popups, and main background now feature subtle purple/blue gradient washes
- **Enhanced Highlights** - Bright edge highlights give panels a premium glass appearance
- **Colored Shadows** - Group icons cast purple-tinted shadows for added depth

#### Menu Bar Toggle
- **Click to Show/Hide** - Left-click the menu bar icon to toggle the launcher visibility
- **Right-Click Menu** - Access "Quit" and other options via right-click
- Matches the global hotkey behavior (⌃⌥Space)

---

## Version 1.4.0 (January 2026)

### New Features

#### Auto-Hide Behavior Settings
- **Hide on Launch** - Automatically hides the launcher when you launch an app (enabled by default)
- **Hide on Focus Lost** - Automatically hides the launcher when you click outside the window (enabled by default)
- Both settings are configurable in the Settings panel and persist between restarts

### Improvements

- **Improved DMG Installer** - Smaller window with larger, centered icons for easier drag-to-install

---

## Version 1.3.0 (January 2026)

### New Features

#### Multi-Select Support
- **Shift+Click** - Select a contiguous range of apps from the last selected app to the clicked app
- **Command+Click** - Toggle individual app selection without affecting other selections
- **Plain Click** (in edit mode) - Clears selection and selects only the clicked app

#### Persistent Group Tile Size
- Group popup tile size setting now persists between app restarts
- Your preferred zoom level is saved automatically

#### Remove from Group
- New "Remove from Group" context menu option when right-clicking apps inside groups
- Quickly move apps back to the ungrouped Apps section

### Improvements

- **Improved Group Popup Height** - Fixed bottom row text being cut off in 16-app groups
- **Sequential Grid Layout** - Apps now fill grid positions sequentially (no gaps in the middle of pages)

---

## Version 1.2.0 (January 2026)

*Internal release with bug fixes*

---

## Version 1.1.0 (January 2026)

### New Features

#### iPad-Style Multi-Page Group Navigation
- **Drag to Edge Page Flip** - Drag an app icon to the left or right edge of a group popup to flip to the previous/next page while maintaining the drag. Drop the app anywhere on the new page.
- **Trackpad Swipe Gestures** - Two-finger horizontal swipe on the trackpad to navigate between pages in multi-page groups
- **Empty Slot System (Voids)** - When moving an app to a different page, an empty slot is left behind on the source page, preserving your layout (up to 4 empty slots per page)
- **Smart Slot Filling** - Apps dropped on a page with empty slots automatically fill the first available slot

#### Enhanced Group Header
- Enlarged group popup header with improved vertical spacing
- Better centered text and close button alignment

### Improvements

- **Simplified Drop Zones** - Drop zones are now completely transparent for a cleaner visual appearance
- **Removed Page Navigation Labels** - The "← Previous" and "Next →" text labels have been removed; navigation is now indicated by arrows and page dots only
- **Removed Edge Zone Chevrons** - Edge drop zones are invisible until activated, providing a cleaner interface
- **Persistent Layout** - App positions and empty slots are now properly saved and restored when relaunching the app
- **Fixed App Icon in Finder** - Build script now correctly copies the app icon to the app bundle

### Bug Fixes

- Fixed issue where void (empty slot) data was not persisting after app restart
- Fixed gesture navigation breaking after dragging apps between pages
- Fixed build script not including AppIcon.icns in the app bundle

---

## Version 1.0.0 (Initial Release)

### Features
- **Quick Launch** - Click any app icon to launch instantly
- **Group Organization** - Organize apps into custom groups (like iOS folders)
- **Global Hotkey** - Press ⌃⌥Space (Control+Option+Space) from anywhere to toggle the launcher
- **Menu Bar Icon** - Always accessible from the menu bar
- **Customizable** - Adjust group colors and tile sizes
- **Search** - Quickly find apps by name
- **Drag & Drop** - Reorder apps and groups with intuitive drag and drop
- **Import/Export** - Back up and restore your settings
- **Translucent Window** - Beautiful semi-transparent design
- **Auto-Save** - Your organization is saved automatically
- **Multi-Page Groups** - Groups with more than 16 apps show multiple pages with navigation

---

*For detailed usage instructions, see the [User Guide](My%20App%20Launcher%20User%20Guide.md).*
