# Claude Code Orchestrator

Maximizes development efficiency when using Claude Code on the Pixr project.

## Quick Start

```bash
# Process all Linear issues automatically
./claude-orchestrator issues

# Fix common issues quickly
./claude-orchestrator fix lint
./claude-orchestrator fix types
./claude-orchestrator fix tests

# Run efficiency analysis
./claude-orchestrator analyze

# Check current status
./claude-orchestrator status
```

## Features

### 🚀 Automated Issue Processing
- Fetches Linear issues via API
- Prioritizes "In Progress" items
- Creates branches automatically
- Commits changes with proper messages

### 🔧 Quick Fix Mode
- Rapidly fixes common issues:
  - Lint errors
  - TypeScript type errors
  - Failing tests
  - Security vulnerabilities
  - Performance bottlenecks

### 📊 Efficiency Analysis
- Identifies code duplication
- Finds performance bottlenecks
- Analyzes test coverage
- Generates optimization tasks

### 💾 Memory Integration
- Persists context across sessions
- Coordinates between tasks
- Tracks progress automatically

## Configuration

Edit `.claude-orchestrator.json` to customize:
- Workflow strategies
- Quality gates
- Automation schedules
- Memory keys

## Best Practices

1. **Always use orchestrator for complex tasks**
   - Multi-step implementations
   - Cross-cutting concerns
   - Large refactorings

2. **Leverage memory for coordination**
   - Store architecture decisions
   - Track issue progress
   - Share context between modes

3. **Use appropriate fix modes**
   - `lint` for code style
   - `types` for TypeScript
   - `tests` for test failures
   - `security` for vulnerabilities
   - `performance` for optimizations

4. **Monitor progress**
   - Check status regularly
   - Review generated tasks
   - Verify automated fixes

## Integration with claude-flow

The orchestrator builds on top of claude-flow:
- Uses SPARC modes intelligently
- Leverages swarm coordination
- Integrates with memory system

## Troubleshooting

If issues arise:
1. Check `./claude-orchestrator status`
2. Review memory contents
3. Verify git status
4. Check logs in `.claude/logs/`