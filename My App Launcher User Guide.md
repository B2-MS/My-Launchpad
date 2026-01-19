# My App Launcher User Guide

A beautiful, native macOS app launcher with group organization, global hotkeys, and a menu bar presence.

---

## Table of Contents
1. [Installation](#installation)
2. [Getting Started](#getting-started)
3. [Menu Bar](#menu-bar)
4. [Global Hotkey](#global-hotkey)
5. [Main Window](#main-window)
6. [Groups](#groups)
7. [Apps](#apps)
8. [Settings](#settings)
9. [Drag and Drop](#drag-and-drop)
10. [Keyboard Shortcuts](#keyboard-shortcuts)

---

## Installation

### From DMG Installer

1. **Download** the `My App Launcher.dmg` file
2. **Double-click** the DMG file to mount it
3. **Drag** "My App Launcher.app" to the **Applications** folder shortcut
4. **Eject** the DMG by right-clicking it in Finder and selecting "Eject"
5. **Launch** the app from your Applications folder

### First-Time Security Prompt

Since this app is not signed with an Apple Developer certificate, macOS will show a security warning on first launch:

#### Method 1: Right-Click to Open
1. Go to your **Applications** folder
2. **Right-click** (or Control-click) on "My App Launcher"
3. Select **"Open"** from the context menu
4. Click **"Open"** in the dialog that appears

#### Method 2: System Settings
1. Try to open the app normally (it will be blocked)
2. Go to **System Settings → Privacy & Security**
3. Scroll down to find the message about "My App Launcher"
4. Click **"Open Anyway"**
5. Enter your password if prompted

### Required Permissions

#### Accessibility Permission (Required for Global Hotkey)
The global hotkey (⌃⌥Space) requires Accessibility permissions:

1. Go to **System Settings → Privacy & Security → Accessibility**
2. Click the **+** button
3. Navigate to **Applications** and select **"My App Launcher.app"**
4. Ensure the toggle is **ON**
5. **Restart the app** after granting permission

> **Important:** If the hotkey stops working after an app update, you may need to remove and re-add the app in Accessibility settings.

### Uninstallation

1. **Quit** the app (click menu bar icon → Quit)
2. **Delete** the app from your Applications folder
3. Optionally remove from **Login Items** in System Settings
4. Optionally remove from **Accessibility** permissions

---

## Getting Started

### First Launch
When you first launch My App Launcher, it will:
- Scan your Applications folder for all installed apps
- Display them in the main window
- Add a grid icon to your menu bar
- Register the global hotkey

### Auto-Start at Login
The app is configured to start automatically when you log in to your Mac. It runs in the background with a menu bar icon, ready to be summoned with the global hotkey.

---

## Menu Bar

The app displays a **grid icon** (⊞) in your menu bar. Click it to access:

- **Show Launcher (⌃⌥Space)** - Opens the main launcher window
- **Quit** - Completely exits the application

The menu bar icon remains visible even when the main window is closed, indicating the app is running in the background.

---

## Global Hotkey

**⌃⌥Space** (Control + Option + Space)

This hotkey works system-wide to toggle the launcher window:
- Press once to **show** the launcher
- Press again to **hide** the launcher

> **Note:** The app requires Accessibility permissions for the global hotkey to work. Grant access in **System Settings → Privacy & Security → Accessibility**.

---

## Main Window

### Window Behavior
- **Red X (Close button)** - Hides the window (app keeps running)
- **Window Transparency** - 95% opacity for a subtle see-through effect
- The window centers on screen when opened

### Sections
The main window has two collapsible sections:

1. **Groups** - Your organized app collections
2. **Apps** - Ungrouped applications (collapsed by default)

Click the section headers to expand/collapse them.

---

## Groups

Groups let you organize apps into collections (like iOS folders).

### Creating a Group
1. Enter **Edit Mode** (click the pencil icon or use settings)
2. Select multiple apps
3. Click "Create Group" or right-click and select "Create New Group"

### Group Display Modes

#### Expanded Mode (Default)
Shows a 2x2 preview of the first 4 apps in the group.

#### Collapsed Mode
Shows a folder icon with a badge indicating the number of apps.

Toggle between modes by clicking the chevron button that appears when hovering over a group.

### Opening a Group
Click on a group to open it in an expanded popup view showing all apps inside.

### Renaming a Group
In the group popup, click the group name in the header to edit it.

### Group Popup Features
- **Pagination** - Groups with more than 16 apps show multiple pages
- **Page Navigation** - Use arrows or dots at the bottom to navigate pages
- **Close** - Click the X button or click outside the popup

---

## Apps

### Launching an App
Simply **click** on any app icon to launch it.

### App Context Menu
Right-click on any app to access:
- **Move to New Group** - Creates a new group with this app
- **Move to Group** - Move the app to an existing group
- **Remove from Group** (when in a group) - Returns app to ungrouped

### App Icons
- Apps display their native macOS icons
- Icons scale based on the group tile size setting
- Hovering over an app shows a subtle highlight effect

---

## Settings

Access settings by clicking the **gear icon** in the top-right corner.

### Available Settings

#### Group Header Color
Choose the color for group popup headers using the color picker. Default is purple.

#### Group Tile Size
Select the size of group tiles:
- **S** (Small) - 0.8x scale
- **M** (Medium) - 1.1x scale (default)
- **L** (Large) - 1.3x scale

#### Save My Settings
Use the Export and Import buttons to back up and restore your launcher configuration.

**Export** - Save all your launcher settings to a JSON file. This includes:
- All groups and their names
- App organization within groups
- Ungrouped app order

Use this to:
- Back up your configuration
- Transfer settings to another Mac
- Share your setup with others

**Import** - Restore settings from a previously exported file. The import process:
- Matches apps by their file path on your system
- Recreates your groups with the same names and organization
- Any apps that no longer exist on your system will be skipped
- New apps not in the imported settings will appear in the ungrouped section

> **Note:** Importing will replace your current groups and organization with the imported settings.

---

## Drag and Drop

### Adding Apps to Groups
Drag an app onto a group icon to add it to that group.

### Reordering Apps Within a Group
In the group popup:
- **Drop ON an app** - Swaps positions with that app
- **Drop to the LEFT of an app** - Inserts before that app (purple highlight shows insertion point)
- **Drop to the RIGHT** - Inserts after (at end of row or end of list)

### Reordering Groups
On the main screen:
- **Drop ON a group** - Swaps positions with that group
- **Drop to the LEFT of a group** - Inserts before that group (blue highlight shows insertion point)
- **Drop to the RIGHT of a group** - Inserts after that group

### Moving Apps Between Groups
Use the context menu to move apps between groups, or drag from ungrouped to a group.

---

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| **⌃⌥Space** | Toggle launcher window (global) |
| **⌘⇧N** | Create new group |
| **⌘Q** | Quit application |

---

## Tips & Tricks

1. **Quick Access** - Use ⌃⌥Space from anywhere to instantly open the launcher
2. **Stay Organized** - Group related apps together (e.g., "Development", "Design", "Games")
3. **Collapse Groups** - Use collapsed mode for groups you access less frequently
4. **Search** - Use the search bar to quickly find apps by name

---

## Troubleshooting

### Hotkey Not Working
1. Check **System Settings → Privacy & Security → Accessibility**
2. Ensure "My App Launcher" is listed and enabled
3. Try removing and re-adding the app to the list
4. Restart the app after granting permissions

### App Not Starting at Login
1. Go to **System Settings → General → Login Items**
2. Add "My App Launcher.app" from the Applications folder

### Missing App Icons
If an app shows a blank icon:
1. The app may have been moved or deleted
2. Try refreshing the app list (relaunch My App Launcher)

---

## System Requirements

- **macOS 13.0** (Ventura) or later
- Accessibility permissions for global hotkey

---

## Version History

### v1.0.0
- Initial release
- Group organization with collapsible tiles
- Global hotkey support (⌃⌥Space)
- Menu bar presence
- Drag and drop reordering
- Customizable group colors and sizes
- Window transparency
- Auto-start at login

---

*My App Launcher - A better way to launch your apps.*
