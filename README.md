# My Launchpad for macOS

A beautiful, native macOS app launcher with group organization, global hotkeys, and menu bar presence.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![Version](https://img.shields.io/badge/Version-1.8.0-purple.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

**[Release Notes](RELEASE_NOTES.md)** | **[User Guide](docs/My%20Launchpad%20User%20Guide.md)**

## Overview

With the release of macOS Tahoe, Apple redesigned Launchpad and removed several beloved features that power users relied on for years. **My Launchpad** brings back that classic experience and adds even more functionality.

### What's Missing in macOS Tahoe?
- ❌ No ability to create custom app groups/folders
- ❌ Limited control over app organization
- ❌ No quick keyboard access from anywhere

### What My Launchpad Provides
- ✅ **Custom Groups** - Organize apps into folders just like the classic Launchpad
- ✅ **Full Reorganization** - Drag and drop to reorder apps and groups exactly how you want
- ✅ **Global Hotkey** - Summon the launcher instantly with ⌃⌥Space from any app
- ✅ **Persistent Layout** - Your organization is saved and syncs across sessions
- ✅ **Import/Export** - Back up your layout or transfer it to another Mac

If you miss the way Launchpad used to work, this app is for you.

## Features

- 🚀 **Quick Launch** - Click any app icon to launch instantly
- 📁 **Group Organization** - Organize apps into custom groups (like iOS folders)
- ⌨️ **Global Hotkey** - Press `⌃⌥Space` (Control+Option+Space) from anywhere to toggle the launcher
- 📍 **Menu Bar Icon** - Click to toggle visibility, right-click for menu
- 🎨 **Customizable** - Adjust group colors and tile sizes
- 📐 **Resizable Groups** - Choose Standard (1x1), Large (2x1), or Extra Large (2x2) tile sizes per group
- 🔍 **Search** - Quickly find apps by name
- 🖱️ **Drag & Drop** - Reorder apps and groups with intuitive drag and drop
- 📄 **Multi-Page Groups** - Groups with 16+ apps paginate automatically with swipe gestures
- 🎯 **iPad-Style Layout** - Drag apps to page edges to move between pages, with empty slot preservation
- ✅ **Multi-Select** - Shift+click for range selection, Command+click for individual toggle
- 💾 **Import/Export** - Back up and restore your settings
- 🪟 **Translucent Window** - Beautiful semi-transparent design
- 💾 **Auto-Save** - Your organization is saved automatically

## Screenshots

*Add your screenshots here*

## Requirements

- macOS 13.0 (Ventura) or later
- Accessibility permission (for global hotkey)

## Installation

### From DMG (Recommended)

1. Download `My Launchpad Installer.dmg` from the [releases](releases) folder
2. Open the DMG and drag **My Launchpad.app** to the **Applications** folder
3. Launch the app and grant Accessibility permission when prompted

### Building from Source

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/my-launchpad.git
cd my-launchpad

# Build with Swift Package Manager
swift build -c release

# Or use the build script
chmod +x scripts/build.sh
./scripts/build.sh
```

## First-Time Setup

### Security Prompt
Since this app isn't signed with an Apple Developer certificate, you'll need to:
1. Right-click the app and select "Open"
2. Click "Open" in the dialog

### Accessibility Permission
For the global hotkey to work:
1. Go to **System Settings → Privacy & Security → Accessibility**
2. Add "My Launchpad" and enable the toggle
3. Restart the app

## Usage

### Basic Controls
- **Click** any app to launch it
- **⌃⌥Space** - Toggle launcher window from anywhere
- **Click menu bar icon** - Show/hide launcher

### Organizing Apps
- **Drag app onto group** - Add app to group
- **Drag app in group** - Reorder (drop on app to swap, drop between apps to insert)
- **Drag groups** - Reorder groups on main screen
- **Right-click app** - Move to group or remove from group

### Settings (Gear Icon)
- **Color** - Customize group header color
- **Size** - Choose tile size (S/M/L)
- **Resize Groups** - Right-click a group → Resize Group → Standard/Large/Extra Large
- **Export** - Save your configuration to a file
- **Import** - Restore configuration from a file

## File Structure

```
MyLaunchpad/
├── Package.swift                 # Swift package definition
├── build.sh                      # Build script
├── README.md                     # This file
├── docs/
│   └── My Launchpad User Guide.md  # Detailed user guide
├── Resources/
│   └── Info.plist               # App metadata
└── Sources/
    ├── MyLaunchpadApp.swift     # Main app, hotkey manager, menu bar
    ├── Models/
    │   ├── AppItem.swift        # App model
    │   └── AppGroup.swift       # Group model
    ├── Services/
    │   ├── AppScanner.swift     # Scans for applications
    │   └── DataManager.swift    # Persistence & import/export
    ├── ViewModels/
    │   └── LauncherViewModel.swift
    └── Views/
        ├── ContentView.swift        # Main window with grid layout
        ├── AppIconView.swift        # App tile
        ├── GroupIconView.swift      # Group tile (supports 1x1, 2x1, 2x2)
        ├── DraggableAppIconView.swift # Draggable app icon wrapper
        ├── StandaloneAppTileView.swift # Standalone app tile
        └── ExpandedGroupView.swift  # Group popup with pagination
```

## Data Storage

Your settings are stored at:
```
~/Library/Application Support/My Launchpad/MyLaunchpadData.json
```

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| ⌃⌥Space | Toggle launcher window (global) |
| ⌘Q | Quit application |

## License

MIT License - Feel free to modify and distribute.

## Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests

## Acknowledgments

Built with SwiftUI and ❤️ for macOS.
