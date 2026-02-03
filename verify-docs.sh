#!/bin/bash

# Documentation Verification Script
# Run this before completing pack-it, send-it, or test-it workflows

echo "📋 Verifying Documentation Updates..."
echo "======================================="

ERRORS=0
WARNINGS=0

# Get current version from README
README_VERSION=$(grep -o 'Version-[0-9.]*' README.md | head -1 | sed 's/Version-//')
echo "📌 Detected version from README: $README_VERSION"
echo ""

# 1. Check README.md version badge
echo "1️⃣  README.md"
if grep -q "Version-$README_VERSION" README.md; then
    echo "   ✅ Version badge present: $README_VERSION"
else
    echo "   ❌ Version badge missing or outdated"
    ((ERRORS++))
fi

# 2. Check RELEASE_NOTES.md has version section
echo ""
echo "2️⃣  RELEASE_NOTES.md"
if grep -q "## Version $README_VERSION" RELEASE_NOTES.md; then
    echo "   ✅ Version $README_VERSION section found"
else
    echo "   ❌ Version $README_VERSION section MISSING"
    ((ERRORS++))
fi

# 3. Check User Guide version history
echo ""
echo "3️⃣  My Launchpad User Guide.md"
# Extract major.minor.patch for comparison
VERSION_PATTERN="v${README_VERSION}"
if grep -q "### $VERSION_PATTERN" "My Launchpad User Guide.md"; then
    echo "   ✅ Version history includes $VERSION_PATTERN"
else
    echo "   ❌ Version history MISSING $VERSION_PATTERN"
    ((ERRORS++))
fi

# 4. Check chat-history.md was updated recently
echo ""
echo "4️⃣  docs/chat-history.md"
CHAT_SESSIONS=$(grep -c "^## Session:" docs/chat-history.md)
echo "   📊 Total sessions documented: $CHAT_SESSIONS"
# Check if today's date appears (for recent updates)
TODAY=$(date "+%B %-d, %Y")
TODAY_SHORT=$(date "+%B %Y")
if grep -q "$TODAY\|$TODAY_SHORT" docs/chat-history.md; then
    echo "   ✅ Recent session entry found"
else
    echo "   ⚠️  No entry with current date found - verify session was added"
    ((WARNINGS++))
fi

# 5. Check prompts-used.md
echo ""
echo "5️⃣  docs/prompts-used.md"
# Check summary exists at top
if head -20 docs/prompts-used.md | grep -q "## Summary"; then
    echo "   ✅ Summary table at top of file"
else
    echo "   ❌ Summary table NOT at top of file"
    ((ERRORS++))
fi

# Count sessions in summary vs actual sessions
SUMMARY_SESSIONS=$(grep -o "[0-9]* Sessions" docs/prompts-used.md | head -1 | grep -o "[0-9]*")
# Exclude template placeholders [Descriptive Topic Title] from count
ACTUAL_SESSIONS=$(grep "^## Session:" docs/prompts-used.md | grep -v "\[Descriptive Topic Title\]" | wc -l | tr -d ' ')
echo "   📊 Summary says: $SUMMARY_SESSIONS sessions"
echo "   📊 Actual sessions: $ACTUAL_SESSIONS"
if [ "$SUMMARY_SESSIONS" = "$ACTUAL_SESSIONS" ]; then
    echo "   ✅ Session count matches"
else
    echo "   ❌ Session count MISMATCH - update summary!"
    ((ERRORS++))
fi

# Count prompts (exclude template lines)
SUMMARY_PROMPTS=$(grep "## Summary" docs/prompts-used.md | grep -o "[0-9]* Prompts" | grep -o "[0-9]*")
ACTUAL_PROMPTS=$(grep "^### Prompt [0-9]*:" docs/prompts-used.md | wc -l | tr -d ' ')
echo "   📊 Summary says: $SUMMARY_PROMPTS prompts"
echo "   📊 Actual prompts: $ACTUAL_PROMPTS"
if [ "$SUMMARY_PROMPTS" = "$ACTUAL_PROMPTS" ]; then
    echo "   ✅ Prompt count matches"
else
    echo "   ❌ Prompt count MISMATCH - update summary!"
    ((ERRORS++))
fi

# 6. Verify sessions are in chronological order
echo ""
echo "6️⃣  Chronological Order Check"
# Extract dates and check order (simplified check)
FIRST_SESSION=$(grep "^## Session:" docs/prompts-used.md | head -1)
LAST_SESSION=$(grep "^## Session:" docs/prompts-used.md | tail -1)
echo "   📅 First session: $FIRST_SESSION"
echo "   📅 Last session: $LAST_SESSION"
echo "   ⚠️  Manually verify chronological order"

# Summary
echo ""
echo "======================================="
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ ALL CHECKS PASSED!"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  PASSED with $WARNINGS warning(s)"
    exit 0
else
    echo "❌ FAILED: $ERRORS error(s), $WARNINGS warning(s)"
    echo ""
    echo "Please fix the issues above before completing the workflow."
    exit 1
fi
