#!/bin/bash

# Send It - Complete release workflow
# Usage: ./send-it.sh [version] [message]
# Example: ./send-it.sh 1.5.6 "Added new feature"

set -e  # Exit on any error

VERSION=${1:-"X.X.X"}
MESSAGE=${2:-"Release updates"}

echo "🚀 SEND IT - Complete Release Workflow"
echo "======================================="
echo "📌 Version: $VERSION"
echo "📝 Message: $MESSAGE"
echo ""

# Step 1: Rebuild and deploy
echo "Step 1: Rebuilding and deploying..."
./rebuild.sh

# Step 2: Verify build
echo ""
echo "Step 2: Verifying build..."
./verify-build.sh

# Step 3: Create DMG
echo ""
echo "Step 3: Creating DMG installer..."
./create-dmg.sh

# Step 4: Verify documentation
echo ""
echo "Step 4: Verifying documentation..."
./verify-docs.sh
if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Documentation verification failed!"
    echo "   Please update docs using: docs/instructions/update-docs.md"
    echo "   Then run: ./send-it.sh $VERSION \"$MESSAGE\""
    exit 1
fi

# Step 5: Git commit and push
echo ""
echo "Step 5: Committing and pushing to GitHub..."
git add -A
git commit -m "Release v$VERSION - $MESSAGE"
git push

echo ""
echo "======================================="
echo "✅ SEND IT COMPLETE!"
echo ""
echo "📍 Released:"
echo "   • Version: $VERSION"
echo "   • DMG: releases/My Launchpad Installer.dmg"
echo "   • Pushed to GitHub"
echo ""
echo "📝 Optional: Create GitHub Release"
echo "   gh release create v$VERSION \"releases/My Launchpad Installer.dmg\" --title \"My Launchpad v$VERSION\" --generate-notes"
