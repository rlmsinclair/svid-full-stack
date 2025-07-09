#!/bin/bash
# Claude Orchestrator: Quick Fix Mode
# Rapidly fixes common issues using parallel processing

set -e

ISSUE_TYPE=$1

if [ -z "$ISSUE_TYPE" ]; then
    echo "Usage: ./quick-fix.sh [lint|types|tests|security|performance]"
    exit 1
fi

echo "🔧 Claude Orchestrator: Quick Fix - $ISSUE_TYPE"
echo "=============================================="

case $ISSUE_TYPE in
    lint)
        echo "🧹 Fixing lint issues..."
        ./claude-flow sparc run coder "Fix all ESLint errors and warnings"
        npm run lint
        ;;
    
    types)
        echo "📝 Fixing TypeScript errors..."
        ./claude-flow sparc run coder "Fix all TypeScript type errors"
        npm run typecheck
        ;;
    
    tests)
        echo "🧪 Fixing failing tests..."
        ./claude-flow sparc run tester "Fix all failing tests and add missing test cases"
        npm run test
        ;;
    
    security)
        echo "🔒 Fixing security vulnerabilities..."
        ./claude-flow sparc run coder "Fix critical security vulnerabilities from SVI-88"
        ;;
    
    performance)
        echo "⚡ Optimizing performance..."
        ./claude-flow sparc run optimizer "Implement performance optimizations for video processing"
        ;;
    
    *)
        echo "❌ Unknown issue type: $ISSUE_TYPE"
        exit 1
        ;;
esac

# Verify fixes
echo "✅ Verifying fixes..."
./claude-flow sparc run reviewer "Verify $ISSUE_TYPE fixes are properly implemented"

# Commit changes
echo "💾 Committing fixes..."
git add -A
git commit -m "fix: Auto-fix $ISSUE_TYPE issues via Claude Orchestrator

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

echo "✨ Quick fix complete for $ISSUE_TYPE!"