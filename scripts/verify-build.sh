#!/bin/bash

# Build Verification Script
# Validates that the build completed successfully and app is functional

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

echo "🔍 Verifying Build..."
echo "====================="

ERRORS=0

# 1. Check app bundle exists
echo ""
echo "1️⃣  App Bundle"
if [ -d "build/My Launchpad.app" ]; then
    echo "   ✅ App bundle exists: build/My Launchpad.app"
else
    echo "   ❌ App bundle NOT FOUND"
    ((ERRORS++))
fi

# 2. Check executable exists
echo ""
echo "2️⃣  Executable"
if [ -f "build/My Launchpad.app/Contents/MacOS/MyLaunchpad" ]; then
    echo "   ✅ Executable exists"
else
    echo "   ❌ Executable NOT FOUND"
    ((ERRORS++))
fi

# 3. Check Info.plist exists
echo ""
echo "3️⃣  Info.plist"
if [ -f "build/My Launchpad.app/Contents/Info.plist" ]; then
    echo "   ✅ Info.plist exists"
    VERSION=$(defaults read "$(pwd)/build/My Launchpad.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null)
    if [ -n "$VERSION" ]; then
        echo "   📌 App Version: $VERSION"
    fi
else
    echo "   ❌ Info.plist NOT FOUND"
    ((ERRORS++))
fi

# 4. Check app is installed in /Applications
echo ""
echo "4️⃣  Installation"
if [ -d "/Applications/My Launchpad.app" ]; then
    echo "   ✅ App installed in /Applications"
else
    echo "   ⚠️  App NOT installed in /Applications (run ./scripts/rebuild.sh)"
fi

# 5. Check app is running
echo ""
echo "5️⃣  Running Status"
if pgrep -f "My Launchpad" > /dev/null 2>&1; then
    echo "   ✅ App is running"
else
    echo "   ⚠️  App is NOT running"
fi

# 6. Check code signature
echo ""
echo "6️⃣  Code Signature"
if codesign -v "build/My Launchpad.app" 2>/dev/null; then
    echo "   ✅ Code signature valid"
else
    echo "   ⚠️  Code signature issue (may be ad-hoc signed)"
fi

# Summary
echo ""
echo "====================="
if [ $ERRORS -eq 0 ]; then
    echo "✅ BUILD VERIFICATION PASSED!"
    exit 0
else
    echo "❌ BUILD VERIFICATION FAILED: $ERRORS error(s)"
    exit 1
fi
