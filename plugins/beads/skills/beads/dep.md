---
name: bd-dep
description: Manage beads issue dependencies.
---

# bd dep

Manage dependencies between issues.

## Understanding Direction

```
bd dep add <issue> <depends-on>
```

This means: `<issue>` **depends on** `<depends-on>`

Or equivalently: `<depends-on>` **blocks** `<issue>`

## Commands

| Command | Description |
|---------|-------------|
| `bd dep add <a> <b>` | a depends on b (b blocks a) |
| `bd dep <blocker> --blocks <blocked>` | Shorthand: blocker blocks blocked |
| `bd dep list <id>` | Show dependencies of an issue |
| `bd dep tree <id>` | Show full dependency tree |
| `bd dep remove <a> <b>` | Remove dependency |
| `bd dep cycles` | Detect circular dependencies |

## Examples

### Adding Dependencies

```bash
# "Write tests" depends on "Implement feature"
bd dep add bd-tests bd-feature

# Equivalent: "Feature" blocks "Tests"
bd dep bd-feature --blocks bd-tests

# Link discovered work to current task
bd dep add bd-new-issue bd-current-work
```

### Viewing Dependencies

```bash
# What does this issue depend on?
bd dep list bd-123

# Full dependency tree
bd dep tree bd-123

# Find circular dependencies
bd dep cycles
```

### Removing Dependencies

```bash
bd dep remove bd-tests bd-feature
```

## Common Patterns

### Discovered Work
When you find new work while working on something:

```bash
# Create the new issue
bd create "Found: need to refactor X" -t task --silent
# Links to current work (new depends on current)
bd dep add bd-new bd-current
```

### Epic with Subtasks
```bash
bd create "Epic: New Feature" -t epic
bd create "Subtask 1" --parent bd-epic
bd create "Subtask 2" --parent bd-epic
```

### Sequential Tasks
```bash
# Task B depends on Task A (A must finish first)
bd dep add bd-task-b bd-task-a
```

## Checking Blocked Work

```bash
bd blocked  # Shows all blocked issues with their blockers
```
