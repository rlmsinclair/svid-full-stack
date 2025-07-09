# Claude Code Orchestrator Guide

## Maximizing Efficiency with Claude Code

This guide documents best practices and workflows for maximizing development efficiency using Claude Code on the Pixr project.

## Core Principles

### 1. Batch Operations
- Always use batch tool operations when reading/writing multiple files
- Group related tasks in single messages for parallel execution
- Use TodoWrite extensively for complex task coordination

### 2. Memory-Driven Development
- Store important context in Memory for cross-session persistence
- Use Memory to coordinate between different development modes
- Track progress and decisions in Memory

### 3. SPARC Mode Selection
Choose the right SPARC mode for each task:
- **orchestrator**: Complex multi-step tasks requiring coordination
- **coder**: Pure implementation tasks
- **researcher**: Information gathering and analysis
- **tdd**: Test-driven feature development
- **architect**: System design and planning

## Efficient Workflows

### 1. Issue Processing Workflow
```bash
# Fetch and analyze issues
./claude-flow sparc run researcher "Analyze all Linear issues and categorize by complexity"

# Store analysis in memory
./claude-flow memory store "issue_analysis" "Complex issues: [...], Simple issues: [...]"

# Process in parallel using swarm
./claude-flow swarm "Implement all simple Linear issues" --strategy development --parallel
```

### 2. Feature Development Workflow
```bash
# Architecture first
./claude-flow sparc run architect "Design [feature] architecture"

# TDD implementation
./claude-flow sparc tdd "[feature description]"

# Code review
./claude-flow sparc run reviewer "Review [feature] implementation"
```

### 3. Batch Processing Workflow
```bash
# Process multiple files
./claude-flow sparc run coder "Update all API endpoints with new authentication"

# Bulk analysis
./claude-flow sparc run analyzer "Find all performance bottlenecks across codebase"
```

## Claude Code Patterns

### Pattern 1: Parallel Task Execution
```javascript
// Use Task tool for parallel execution
Task("Frontend Implementation", "Implement React components for video player");
Task("Backend API", "Create video processing endpoints");
Task("Database Schema", "Design video metadata schema");
```

### Pattern 2: Memory Coordination
```javascript
// Store architecture decisions
Memory.store("video_player_arch", {
  framework: "React",
  state: "Redux",
  streaming: "HLS"
});

// Reference in other tasks
Task("Player UI", "Implement UI using video_player_arch from Memory");
```

### Pattern 3: Progressive Enhancement
```javascript
// Start simple, enhance iteratively
TodoWrite([
  { content: "Basic implementation", priority: "high" },
  { content: "Add error handling", priority: "medium" },
  { content: "Performance optimization", priority: "low" }
]);
```

## Automation Scripts

### 1. Auto-Issue Processor
```bash
#!/bin/bash
# auto-process-issues.sh
./claude-flow sparc "Fetch all Linear issues and create implementation plans"
./claude-flow memory store "issue_queue" "$(linear-fetch.js)"
./claude-flow swarm "Process issue queue from memory" --parallel
```

### 2. Daily Standup Generator
```bash
#!/bin/bash
# daily-standup.sh
./claude-flow memory get "yesterday_progress"
./claude-flow sparc run analyzer "Generate standup report from git commits and completed todos"
```

### 3. Code Quality Check
```bash
#!/bin/bash
# quality-check.sh
./claude-flow sparc run reviewer "Review recent changes for quality issues"
./claude-flow sparc run tester "Generate missing tests for new code"
```

## Efficiency Tips

### 1. Context Management
- Keep CLAUDE.md updated with project-specific patterns
- Use Memory to store frequently needed information
- Create templates for common tasks

### 2. Batch Operations
- Group file reads: `Read(["file1.js", "file2.js", "file3.js"])`
- Batch edits: `MultiEdit` for multiple changes to same file
- Parallel git operations

### 3. Smart Task Ordering
- Prioritize blocking tasks
- Group similar tasks together
- Use dependency chains in TodoWrite

### 4. Leverage Existing Tools
- Use `./claude-flow` commands instead of manual operations
- Utilize pre-built SPARC modes
- Reference existing documentation in .claude/commands/

## Common Pitfalls to Avoid

### 1. Sequential Processing
❌ Processing issues one by one
✅ Batch process with swarm mode

### 2. Context Loss
❌ Repeating analysis across sessions
✅ Store analysis results in Memory

### 3. Mode Misuse
❌ Using coder mode for research tasks
✅ Match SPARC mode to task type

### 4. Manual Coordination
❌ Manually tracking task progress
✅ Use TodoWrite and Memory for coordination

## Integration with Pixr

### Video Processing Optimization
```bash
# Analyze current bottlenecks
./claude-flow sparc run analyzer "Profile video processing pipeline"

# Implement improvements
./claude-flow swarm "Optimize video processing" --strategy optimization
```

### DeFi Implementation
```bash
# Research best practices
./claude-flow sparc run researcher "DeFi implementation patterns for video platform"

# Implement with TDD
./claude-flow sparc tdd "PIX token calculations and distribution"
```

## Metrics and Monitoring

Track efficiency improvements:
- Time per issue resolution
- Code quality metrics
- Test coverage changes
- Performance improvements

## Continuous Improvement

1. Regular workflow reviews
2. Update this guide with new patterns
3. Share learnings in Memory
4. Optimize based on metrics

---

*Remember: The goal is to maximize developer productivity while maintaining code quality and following North Star principles.*