#!/bin/bash

# Test It - Quick rebuild, deploy, and verify
# Usage: ./test-it.sh

set -e  # Exit on any error

echo "🧪 TEST IT - Rebuild & Deploy for Testing"
echo "=========================================="

# Step 1: Rebuild and deploy
echo ""
echo "Step 1: Rebuilding and deploying..."
./rebuild.sh

# Step 2: Verify build
echo ""
echo "Step 2: Verifying build..."
./verify-build.sh

echo ""
echo "=========================================="
echo "✅ TEST IT COMPLETE!"
echo ""
echo "📝 Next steps:"
echo "   1. Test the app manually"
echo "   2. Update docs: see docs/instructions/update-docs.md"
echo "   3. Verify docs: ./verify-docs.sh"
