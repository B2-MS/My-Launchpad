#!/bin/bash

# Test It - Quick rebuild, deploy, and verify
# Usage: ./scripts/test-it.sh

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

echo "🧪 TEST IT - Rebuild & Deploy for Testing"
echo "=========================================="

# Step 1: Rebuild and deploy
echo ""
echo "Step 1: Rebuilding and deploying..."
"$SCRIPT_DIR/rebuild.sh"

# Step 2: Verify build
echo ""
echo "Step 2: Verifying build..."
"$SCRIPT_DIR/verify-build.sh"

echo ""
echo "=========================================="
echo "✅ TEST IT COMPLETE!"
echo ""
echo "📝 Next steps:"
echo "   1. Test the app manually"
echo "   2. Update docs: see docs/instructions/test-it.md"
echo "   3. Verify docs: ./scripts/verify-docs.sh"
