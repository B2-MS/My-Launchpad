#!/bin/bash

# Pack It - Build, deploy, create DMG, and verify
# Usage: ./scripts/pack-it.sh

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

echo "📦 PACK IT - Build, Deploy & Package"
echo "====================================="

# Step 1: Rebuild and deploy
echo ""
echo "Step 1: Rebuilding and deploying..."
"$SCRIPT_DIR/rebuild.sh"

# Step 2: Verify build
echo ""
echo "Step 2: Verifying build..."
"$SCRIPT_DIR/verify-build.sh"

# Step 3: Create DMG
echo ""
echo "Step 3: Creating DMG installer..."
"$SCRIPT_DIR/create-dmg.sh"

echo ""
echo "====================================="
echo "✅ PACK IT COMPLETE!"
echo ""
echo "📝 Next steps:"
echo "   1. Update docs: see docs/instructions/pack-it.md"
echo "   2. Verify docs: ./scripts/verify-docs.sh"
echo ""
echo "📍 Output files:"
echo "   • App: build/My Launchpad.app"
echo "   • DMG: releases/My Launchpad Installer.dmg"
