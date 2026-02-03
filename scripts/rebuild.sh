#!/bin/bash

# Rebuild and Redeploy Script
# Builds the app, stops running instances, reinstalls, and launches

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

echo "🔄 Rebuild and Redeploy My Launchpad"
echo "====================================="

# 1. Build the app
echo ""
echo "1️⃣  Building app..."
"$SCRIPT_DIR/build.sh"
if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# 2. Stop running instances
echo ""
echo "2️⃣  Stopping running instances..."
pkill -9 -f "My Launchpad" 2>/dev/null
sleep 1

# 3. Remove installed version
echo ""
echo "3️⃣  Removing old version from /Applications..."
rm -rf "/Applications/My Launchpad.app"

# 4. Install new version
echo ""
echo "4️⃣  Installing new version to /Applications..."
cp -R "build/My Launchpad.app" "/Applications/"

# 5. Launch the app
echo ""
echo "5️⃣  Launching app..."
open "/Applications/My Launchpad.app"

echo ""
echo "====================================="
echo "✅ Rebuild and redeploy complete!"
