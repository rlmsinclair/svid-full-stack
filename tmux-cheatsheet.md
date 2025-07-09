# Tmux Quick Reference

## Starting Tmux
```bash
tmux                    # Start new session
tmux new -s name        # Start new session with name
tmux attach             # Attach to last session
tmux attach -t name     # Attach to named session
tmux ls                 # List sessions
tmux kill-session -t name # Kill session
```

## Key Bindings (Prefix = Ctrl-A)

### Session Management
- `Prefix + S` - Choose session
- `Prefix + N` - New session
- `Prefix + d` - Detach from session

### Window Management
- `Prefix + c` - Create new window
- `Prefix + ,` - Rename window
- `Prefix + &` - Kill window
- `Prefix + 0-9` - Switch to window by number
- `Prefix + Tab` - Last window
- `Prefix + C-h` - Previous window
- `Prefix + C-l` - Next window

### Pane Management
- `Prefix + |` - Split horizontally
- `Prefix + -` - Split vertically
- `Prefix + x` - Kill pane
- `Prefix + z` - Toggle pane zoom
- `Prefix + !` - Convert pane to window

### Pane Navigation
- `Prefix + h/j/k/l` - Navigate panes (vim-style)
- `Ctrl + h/j/k/l` - Smart navigation (works with vim)
- `Alt + ←/→/↑/↓` - Quick pane switching

### Pane Resizing
- `Prefix + H/J/K/L` - Resize panes (repeatable)

### Copy Mode
- `Prefix + [` - Enter copy mode
- `v` - Start selection (in copy mode)
- `y` - Copy selection
- `Prefix + ]` - Paste

### Other
- `Prefix + r` - Reload configuration
- `Prefix + ?` - Show all key bindings

## Best Practices

1. **Use sessions for projects** - Create a session per project
2. **Name your sessions** - Use descriptive names
3. **Organize with windows** - Use windows for different tasks
4. **Save layouts** - Use tmux-resurrect or tmux-continuum plugins
5. **Use pane synchronization** - `Prefix + :setw synchronize-panes`

## Advanced Tips

### Start tmux automatically
Add to your shell profile (~/.zshrc or ~/.bashrc):
```bash
# Auto-start tmux
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  exec tmux new-session -A -s main
fi
```

### Useful aliases
```bash
alias ta='tmux attach -t'
alias tad='tmux attach -d -t'
alias ts='tmux new-session -s'
alias tl='tmux list-sessions'
alias tksv='tmux kill-server'
alias tkss='tmux kill-session -t'
```