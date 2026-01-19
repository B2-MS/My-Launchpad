#!/bin/bash

# Build script for App Launcher
# This script compiles the SwiftUI app and creates a proper macOS .app bundle

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
APP_NAME="My App Launcher"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
EXECUTABLE_NAME="AppLauncher"

echo "🔨 Building App Launcher..."

# Quit the app if it's running
echo "🛑 Stopping any running instances..."
pkill -f "App Launcher" 2>/dev/null || true
pkill -f "AppLauncher" 2>/dev/null || true
sleep 1

# Clean previous build
echo "🧹 Cleaning previous build..."
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

# Copy app icon
if [ -f "$SCRIPT_DIR/Resources/AppIcon.icns" ]; then
    cp "$SCRIPT_DIR/Resources/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/"
fi

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

# Automatically open the app
echo "🚀 Launching app..."
open "$APP_BUNDLE"
