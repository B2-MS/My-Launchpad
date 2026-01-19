#!/bin/bash

# Build script for App Launcher
# This script compiles the SwiftUI app and creates a proper macOS .app bundle

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
APP_NAME="App Launcher"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
EXECUTABLE_NAME="AppLauncher"

echo "🔨 Building App Launcher..."

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Build the executable using Swift Package Manager
echo "📦 Compiling with Swift..."
cd "$SCRIPT_DIR"
swift build -c release

# Get the built executable path
BUILT_EXECUTABLE="$SCRIPT_DIR/.build/release/$EXECUTABLE_NAME"

if [ ! -f "$BUILT_EXECUTABLE" ]; then
    echo "❌ Build failed - executable not found"
    exit 1
fi

echo "📁 Creating app bundle..."

# Create app bundle structure
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Copy executable
cp "$BUILT_EXECUTABLE" "$APP_BUNDLE/Contents/MacOS/$EXECUTABLE_NAME"

# Copy Info.plist
cp "$SCRIPT_DIR/Resources/Info.plist" "$APP_BUNDLE/Contents/"

# Create PkgInfo
echo -n "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"

# Sign the app (ad-hoc signing for local use)
echo "🔐 Signing app bundle..."
codesign --force --deep --sign - "$APP_BUNDLE" 2>/dev/null || echo "⚠️  Code signing skipped (run as needed)"

echo ""
echo "✅ Build successful!"
echo ""
echo "📍 App location: $APP_BUNDLE"
echo ""
echo "To install, you can:"
echo "  1. Double-click the app to run it"
echo "  2. Drag it to your Applications folder"
echo "  3. Run: open \"$APP_BUNDLE\""
echo ""

# Ask if user wants to open the app
read -p "Would you like to open the app now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "$APP_BUNDLE"
fi
