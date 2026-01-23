# Release Notes

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
