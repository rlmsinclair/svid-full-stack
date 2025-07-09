#!/bin/bash
# Claude Orchestrator: Automated Linear Issue Processing
# This script fetches Linear issues and processes them efficiently using Claude Code

set -e

echo "🚀 Claude Orchestrator: Linear Issue Processor"
echo "============================================="

# Fetch latest issues
echo "📥 Fetching Linear issues..."
node linear-fetch.js > linear-issues-latest.json

# Store in memory for coordination
echo "💾 Storing issues in Memory..."
./claude-flow memory store "linear_issues_queue" "$(cat linear-issues-latest.json)"

# Get issue count
TOTAL_ISSUES=$(jq '.total' linear-issues-latest.json)
IN_PROGRESS=$(jq '.inProgress | length' linear-issues-latest.json)
BACKLOG=$(jq '.backlog | length' linear-issues-latest.json)

echo "📊 Issue Summary:"
echo "  - Total: $TOTAL_ISSUES"
echo "  - In Progress: $IN_PROGRESS"
echo "  - Backlog: $BACKLOG"

# Process based on priority
if [ $IN_PROGRESS -gt 0 ]; then
    echo "🔥 Processing In Progress issues first..."
    ./claude-flow swarm "Process all Linear In Progress issues from memory" \
        --strategy development \
        --mode hierarchical \
        --max-agents 5 \
        --parallel \
        --output json > in-progress-results.json
fi

# Check if we should continue with backlog
read -p "Continue with backlog processing? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📋 Processing backlog issues..."
    ./claude-flow swarm "Process Linear backlog issues from memory" \
        --strategy development \
        --mode distributed \
        --max-agents 10 \
        --parallel \
        --monitor
fi

# Generate summary report
echo "📝 Generating completion report..."
./claude-flow sparc run analyzer "Generate Linear issue processing report from memory"

echo "✅ Issue processing complete!"