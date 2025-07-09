#!/bin/bash

# PR Compatibility Analyzer Script
# Usage: ./analyze-pr-compatibility.sh <pr1> <pr2> <pr3>

set -e

PR1=${1:-5}
PR2=${2:-7}
PR3=${3:-8}

echo "==================================="
echo "PR Compatibility Analysis"
echo "==================================="
echo "Analyzing PRs: #$PR1, #$PR2, #$PR3"
echo ""

# Function to check PR details
check_pr() {
    local pr_num=$1
    echo "Checking PR #$pr_num..."
    
    # Get PR info
    gh pr view $pr_num --json title,state,files,additions,deletions,mergeable 2>/dev/null || {
        echo "  ❌ PR #$pr_num not found"
        return 1
    }
    
    # Get changed files
    echo "  Changed files:"
    gh pr diff $pr_num --name-only 2>/dev/null | head -10 | sed 's/^/    /'
    
    # Check for migrations
    echo "  Database migrations:"
    gh pr diff $pr_num --name-only 2>/dev/null | grep -E "(migrate|migration|\.sql)" | sed 's/^/    /' || echo "    None found"
    
    # Check for conflicts
    echo "  Merge conflicts:"
    gh pr view $pr_num --json mergeable --jq '.mergeable' | sed 's/^/    /'
    
    echo ""
}

# Function to find overlapping files
find_overlaps() {
    echo "Checking for file overlaps..."
    
    # Get file lists
    PR1_FILES=$(gh pr diff $PR1 --name-only 2>/dev/null || echo "")
    PR2_FILES=$(gh pr diff $PR2 --name-only 2>/dev/null || echo "")
    PR3_FILES=$(gh pr diff $PR3 --name-only 2>/dev/null || echo "")
    
    # Find overlaps between PR1 and PR2
    echo "  Overlaps between PR #$PR1 and PR #$PR2:"
    comm -12 <(echo "$PR1_FILES" | sort) <(echo "$PR2_FILES" | sort) | sed 's/^/    /' || echo "    None"
    
    # Find overlaps between PR1 and PR3
    echo "  Overlaps between PR #$PR1 and PR #$PR3:"
    comm -12 <(echo "$PR1_FILES" | sort) <(echo "$PR3_FILES" | sort) | sed 's/^/    /' || echo "    None"
    
    # Find overlaps between PR2 and PR3
    echo "  Overlaps between PR #$PR2 and PR #$PR3:"
    comm -12 <(echo "$PR2_FILES" | sort) <(echo "$PR3_FILES" | sort) | sed 's/^/    /' || echo "    None"
    
    echo ""
}

# Function to analyze scope
analyze_scope() {
    local pr_num=$1
    echo "Analyzing scope of PR #$pr_num..."
    
    # Get stats
    STATS=$(gh pr view $pr_num --json additions,deletions 2>/dev/null || echo "{}")
    ADDITIONS=$(echo $STATS | jq -r '.additions // 0')
    DELETIONS=$(echo $STATS | jq -r '.deletions // 0')
    TOTAL=$((ADDITIONS + DELETIONS))
    
    echo "  Lines changed: +$ADDITIONS -$DELETIONS (Total: $TOTAL)"
    
    # Categorize based on size
    if [ $TOTAL -gt 1000 ]; then
        echo "  ⚠️  WARNING: Large PR (>1000 lines) - Consider splitting"
    elif [ $TOTAL -gt 500 ]; then
        echo "  ⚠️  CAUTION: Medium PR (>500 lines)"
    else
        echo "  ✅ Reasonable size PR (<500 lines)"
    fi
    
    # Check file diversity
    FILE_COUNT=$(gh pr diff $pr_num --name-only 2>/dev/null | wc -l || echo 0)
    echo "  Files changed: $FILE_COUNT"
    
    if [ $FILE_COUNT -gt 20 ]; then
        echo "  ⚠️  WARNING: Many files changed - Possible scope creep"
    fi
    
    echo ""
}

# Function to check for migration conflicts
check_migration_conflicts() {
    echo "Checking for database migration conflicts..."
    
    # Get all migration files from all PRs
    ALL_MIGRATIONS=""
    for pr in $PR1 $PR2 $PR3; do
        MIGRATIONS=$(gh pr diff $pr --name-only 2>/dev/null | grep -E "(db/migrate|migrations/)" || echo "")
        ALL_MIGRATIONS="$ALL_MIGRATIONS$MIGRATIONS"
    done
    
    # Check for duplicate migration numbers
    echo "$ALL_MIGRATIONS" | grep -oE "[0-9]{14}" | sort | uniq -d | while read dup; do
        echo "  ⚠️  Duplicate migration timestamp found: $dup"
    done
    
    echo ""
}

# Function to generate merge order recommendation
recommend_merge_order() {
    echo "==================================="
    echo "Recommended Merge Order"
    echo "==================================="
    
    # This is a simplified recommendation
    # In reality, you'd want more sophisticated analysis
    
    echo "1. First merge: PR with no conflicts and smallest scope"
    echo "2. Second merge: Infrastructure changes (if isolated)"
    echo "3. Last merge: PRs with conflicts or large scope (after splitting)"
    echo ""
    
    echo "Specific recommendations based on analysis:"
    echo "- PRs with conflicts should be rebased first"
    echo "- Large PRs (>500 lines) should be split"
    echo "- Migration conflicts must be resolved before merging"
}

# Main execution
main() {
    # Check if gh CLI is installed
    if ! command -v gh &> /dev/null; then
        echo "Error: GitHub CLI (gh) is not installed"
        echo "Install it from: https://cli.github.com/"
        exit 1
    fi
    
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is not installed"
        echo "Install it with: brew install jq"
        exit 1
    fi
    
    # Run analysis
    check_pr $PR1
    check_pr $PR2
    check_pr $PR3
    
    find_overlaps
    
    analyze_scope $PR1
    analyze_scope $PR2
    analyze_scope $PR3
    
    check_migration_conflicts
    
    recommend_merge_order
}

# Run main function
main