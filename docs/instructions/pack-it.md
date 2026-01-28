# Pack It Up Instructions

Instructions for packaging and distributing My Launchpad.

## Prerequisites

- macOS with Xcode Command Line Tools installed
- Swift Package Manager (included with Xcode)

## Scripts Overview

| Script | Purpose |
|--------|---------|
| `build.sh` | Full build with app bundle creation and auto-launch |
| `deploy.sh` | Quick rebuild and launch (for development) |
| `create-dmg.sh` | Create distributable DMG installer |

---

## Option 1: Full Build (`build.sh`)

Use this for a clean, complete build:

```bash
./build.sh
```

**What it does:**
1. 🛑 Stops any running instances of the app
2. 🧹 Cleans previous build directory
3. 📦 Compiles with `swift build -c release`
4. 📁 Creates app bundle structure:
   - `build/My Launchpad.app/Contents/MacOS/` - executable
   - `build/My Launchpad.app/Contents/Resources/` - icons
   - `build/My Launchpad.app/Contents/Info.plist`
   - `build/My Launchpad.app/Contents/PkgInfo`
5. 🔐 Ad-hoc code signs the app
6. 🚀 Automatically launches the app

---

## Option 2: Quick Deploy (`deploy.sh`)

Use this for rapid iteration during development:

```bash
./deploy.sh
```

**What it does:**
1. Kills any stale Swift processes
2. Runs `swift build -c release`
3. Creates minimal app bundle
4. Code signs and launches

---

## Option 3: Create DMG Installer (`create-dmg.sh`)

Use this to create a distributable DMG:

```bash
./create-dmg.sh
```

**Prerequisites:** Run `build.sh` first to create the app bundle.

**What it does:**
1. 📦 Verifies app bundle exists
2. 🔌 Unmounts any existing volumes
3. 📁 Prepares DMG contents with Applications symlink
4. 💿 Creates read-write DMG image
5. 🔧 Customizes DMG window appearance:
   - Sets icon view with 128px icons
   - Positions app icon on left, Applications folder on right
   - Configures window size (400x250)
6. 🗜️ Converts to compressed read-only DMG

---

## Complete Pack It Up Workflow

For a full release build:

```bash
# 1. Build the application
./build.sh

# 2. Stop all running instances
pkill -f "My Launchpad" 2>/dev/null

# 3. Remove installed version from Applications
rm -rf "/Applications/My Launchpad.app"

# 4. Install new version to Applications
cp -R "build/My Launchpad.app" "/Applications/"

# 5. Update ALL markdown files (README.md, RELEASE_NOTES.md, User Guide)
# - Update version badge in README.md
# - Add new version section to RELEASE_NOTES.md
# - Update User Guide with any new features/behavior

# 6. Launch the new version
open "/Applications/My Launchpad.app"
```

### One-Liner for Steps 1-4 & 6

```bash
./build.sh && pkill -f "My Launchpad" 2>/dev/null; rm -rf "/Applications/My Launchpad.app" && cp -R "build/My Launchpad.app" "/Applications/" && open "/Applications/My Launchpad.app"
```

### Markdown Files Checklist

| File | What to Update |
|------|----------------|
| `README.md` | Version badge (e.g., `Version-1.5.2-purple`) |
| `RELEASE_NOTES.md` | Add new version section at top with changes |
| `My Launchpad User Guide.md` | Document any new features or behavior changes |

## Output Files

| File | Location |
|------|----------|
| App Bundle | `build/My Launchpad.app` |
| DMG Installer | `My Launchpad Installer.dmg` |

## Troubleshooting

### Build fails - executable not found
- Ensure Swift is installed: `swift --version`
- Check for compilation errors in the output

### Code signing warnings
- Ad-hoc signing (`--sign -`) is used for local testing
- For distribution, use a valid Developer ID certificate

### DMG creation fails
- Ensure the app bundle exists (run `build.sh` first)
- Check for mounted volumes with the same name
