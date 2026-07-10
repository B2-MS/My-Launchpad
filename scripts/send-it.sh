#!/bin/bash

# Send It - Complete release workflow
# Usage: ./scripts/send-it.sh [version] [message]
# Example: ./scripts/send-it.sh 1.5.6 "Added new feature"

set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

VERSION=${1:-"X.X.X"}
MESSAGE=${2:-"Release updates"}
RETRY_DELAY_SECONDS=${RETRY_DELAY_SECONDS:-15}

run_workflow() {
    # Step 1: Rebuild and deploy
    echo "Step 1: Rebuilding and deploying..."
    "$SCRIPT_DIR/rebuild.sh" || return $?

    # Step 2: Verify build
    echo ""
    echo "Step 2: Verifying build..."
    "$SCRIPT_DIR/verify-build.sh" || return $?

    # Step 3: Create DMG
    echo ""
    echo "Step 3: Creating DMG installer..."
    "$SCRIPT_DIR/create-dmg.sh" || return $?

    # Step 4: Verify documentation
    echo ""
    echo "Step 4: Verifying documentation..."
    "$SCRIPT_DIR/verify-docs.sh" || return $?

    # Step 5: Git commit and push
    echo ""
    echo "Step 5: Committing and pushing to GitHub..."
    git add -A || return $?

    if git diff --cached --quiet; then
        echo "No staged changes to commit. Skipping commit."
    else
        git commit -m "Release v$VERSION - $MESSAGE" || return $?
    fi

    git push || return $?

    return 0
}

echo "🚀 SEND IT - Complete Release Workflow"
echo "======================================="
echo "📌 Version: $VERSION"
echo "📝 Message: $MESSAGE"
echo "🔁 Retry delay: ${RETRY_DELAY_SECONDS}s"
echo "🛑 Press Ctrl+C to stop automatic retries"
echo ""

ATTEMPT=1
while true; do
    echo "======================================="
    echo "🚀 Attempt #$ATTEMPT"
    echo "======================================="

    if run_workflow; then
        break
    fi

    EXIT_CODE=$?
    echo ""
    echo "❌ SEND IT attempt #$ATTEMPT failed (exit code: $EXIT_CODE)."
    echo "⏳ Retrying in ${RETRY_DELAY_SECONDS}s..."
    sleep "$RETRY_DELAY_SECONDS"
    ATTEMPT=$((ATTEMPT + 1))
done

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
