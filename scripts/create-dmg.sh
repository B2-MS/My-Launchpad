#!/bin/bash

# Create a proper DMG installer for My Launchpad
# This creates a DMG with the app and an Applications shortcut for drag-to-install

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"
RELEASES_DIR="$PROJECT_DIR/releases"
APP_NAME="My Launchpad"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
DMG_NAME="My Launchpad Installer.dmg"
DMG_PATH="$RELEASES_DIR/$DMG_NAME"
TEMP_DMG="$PROJECT_DIR/temp_$DMG_NAME"
VOLUME_NAME="$APP_NAME"

echo "📦 Creating DMG installer for $APP_NAME..."

# Ensure releases directory exists
mkdir -p "$RELEASES_DIR"

# Check if the app exists
if [ ! -d "$APP_BUNDLE" ]; then
    echo "❌ App bundle not found at: $APP_BUNDLE"
    echo "   Run build.sh first to create the app bundle."
    exit 1
fi

# Unmount any existing volume with the same name
echo "🔌 Unmounting any existing volumes..."
hdiutil detach "/Volumes/$VOLUME_NAME" 2>/dev/null || true

# Remove existing DMG files
rm -f "$DMG_PATH"
rm -f "$TEMP_DMG"

# Create a temporary directory for DMG contents
TEMP_DIR=$(mktemp -d)
echo "📁 Preparing DMG contents..."

# Copy the app to temp directory
cp -R "$APP_BUNDLE" "$TEMP_DIR/"

# Create Applications symlink for drag-to-install
ln -s /Applications "$TEMP_DIR/Applications"

# Calculate size needed (app size + 10MB buffer)
APP_SIZE=$(du -sm "$APP_BUNDLE" | cut -f1)
DMG_SIZE=$((APP_SIZE + 10))

echo "💿 Creating DMG image (${DMG_SIZE}MB)..."

# Create the DMG
hdiutil create -srcfolder "$TEMP_DIR" \
    -volname "$VOLUME_NAME" \
    -fs HFS+ \
    -fsargs "-c c=64,a=16,e=16" \
    -format UDRW \
    -size ${DMG_SIZE}m \
    "$TEMP_DMG"

# Mount the DMG
echo "🔧 Customizing DMG appearance..."
DEVICE=$(hdiutil attach -readwrite -noverify "$TEMP_DMG" | grep "Apple_HFS" | awk '{print $1}')

# Set custom window appearance using AppleScript
osascript <<EOF
tell application "Finder"
    tell disk "$VOLUME_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set bounds of container window to {300, 100, 940, 520}
        set theViewOptions to the icon view options of container window
        set arrangement of theViewOptions to not arranged
        set icon size of theViewOptions to 128
        
        -- Position the app icon on the left-center
        set position of item "$APP_NAME.app" of container window to {160, 190}
        
        -- Position Applications folder on the right-center
        set position of item "Applications" of container window to {480, 190}
        
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
EOF

# Sync and unmount
sync
hdiutil detach "$DEVICE"

# Convert to compressed read-only DMG
echo "🗜️  Compressing DMG..."
hdiutil convert "$TEMP_DMG" -format UDZO -imagekey zlib-level=9 -o "$DMG_PATH"

# Cleanup
rm -f "$TEMP_DMG"
rm -rf "$TEMP_DIR"

echo ""
echo "✅ DMG created successfully!"
echo ""
echo "📍 DMG location: $DMG_PATH"
echo "📊 Size: $(du -h "$DMG_PATH" | cut -f1)"
echo ""
echo "The DMG contains:"
echo "  • $APP_NAME.app"
echo "  • Applications shortcut (for drag-to-install)"
