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
if [ ! -f ".build/release/MyLaunchpad" ]; then
    echo "Build failed - executable not found"
    exit 1
fi

# Create app bundle
rm -rf build
mkdir -p "build/My Launchpad.app/Contents/MacOS"
mkdir -p "build/My Launchpad.app/Contents/Resources"
cp .build/release/MyLaunchpad "build/My Launchpad.app/Contents/MacOS/"
cp Resources/Info.plist "build/My Launchpad.app/Contents/"
printf 'APPL????' > "build/My Launchpad.app/Contents/PkgInfo"
codesign --force --deep --sign - "build/My Launchpad.app" 2>/dev/null

echo "Build complete!"
open "build/My Launchpad.app"
