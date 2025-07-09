#!/bin/bash
# Claude Orchestrator: Development Efficiency Analyzer
# Analyzes codebase and suggests optimizations

set -e

echo "🔍 Claude Orchestrator: Efficiency Analyzer"
echo "=========================================="

# Analyze current codebase state
echo "📊 Analyzing codebase metrics..."

# Check for duplicate code
echo "🔄 Checking for code duplication..."
./claude-flow sparc run analyzer "Find duplicate code patterns that can be refactored"

# Analyze performance bottlenecks
echo "⚡ Analyzing performance bottlenecks..."
./claude-flow sparc run analyzer "Identify performance bottlenecks in video processing pipeline"

# Review test coverage
echo "🧪 Analyzing test coverage..."
./claude-flow sparc run tester "Analyze test coverage and identify critical untested paths"

# Check for security issues
echo "🔒 Running security analysis..."
./claude-flow sparc run reviewer "Security audit focusing on critical vulnerabilities"

# Generate optimization tasks
echo "📝 Generating optimization tasks..."
./claude-flow sparc run orchestrator "Create prioritized optimization task list based on analysis"

# Store results in memory
echo "💾 Storing analysis results..."
./claude-flow memory store "efficiency_analysis_$(date +%Y%m%d)" "Analysis complete - check logs"

echo "✅ Efficiency analysis complete!"
echo "📋 Check generated optimization tasks in TodoList"