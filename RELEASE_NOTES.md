# Release Notes

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
