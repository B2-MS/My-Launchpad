#!/bin/bash
# Quick deploy script - creates app bundle from existing build

cd "$(dirname "$0")"

# Kill any stale Swift processes
pkill -f "swift-build" 2>/dev/null
pkill -f "swift-frontend" 2>/dev/null
sleep 1

# Build
echo "Building..."
swift build -c release

# Check if build succeeded
if [ ! -f ".build/release/AppLauncher" ]; then
    echo "Build failed - executable not found"
    exit 1
fi

# Create app bundle
rm -rf build
mkdir -p "build/App Launcher.app/Contents/MacOS"
mkdir -p "build/App Launcher.app/Contents/Resources"
cp .build/release/AppLauncher "build/App Launcher.app/Contents/MacOS/"
cp Resources/Info.plist "build/App Launcher.app/Contents/"
printf 'APPL????' > "build/App Launcher.app/Contents/PkgInfo"
codesign --force --deep --sign - "build/App Launcher.app" 2>/dev/null

echo "Build complete!"
open "build/App Launcher.app"
