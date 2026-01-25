#!/bin/bash

# Alternative build script that creates an Xcode project
# Use this if you prefer building through Xcode

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/MyLaunchpad.xcodeproj"

echo "🔨 Creating Xcode project for My Launchpad..."

# Generate Xcode project from Package.swift
cd "$SCRIPT_DIR"
swift package generate-xcodeproj 2>/dev/null || {
    echo ""
    echo "⚠️  Could not generate Xcode project automatically."
    echo ""
    echo "You can build manually:"
    echo "  1. Open Xcode"
    echo "  2. File > Open > Select the MyLaunchpad folder"
    echo "  3. Xcode will recognize Package.swift"
    echo "  4. Select 'My Mac' as the run destination"
    echo "  5. Press Cmd+R to build and run"
    echo ""
    exit 0
}

echo ""
echo "✅ Xcode project created!"
echo ""
echo "📍 Project location: $PROJECT_DIR"
echo ""
echo "To build:"
echo "  1. Open $PROJECT_DIR in Xcode"
echo "  2. Select 'My Mac' as destination"
echo "  3. Press Cmd+B to build or Cmd+R to run"
echo ""

read -p "Open in Xcode now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "$PROJECT_DIR"
fi
