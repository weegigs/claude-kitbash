---
name: jj-workspace
description: Manage jj workspaces in a well-known location (~/.jj-workspaces) for parallel agent work. Use when spawning isolated work environments for beads tasks.
---

# jj-workspace Skill

Manage jj workspaces in `~/.jj-workspaces/<project>/<task-name>` for isolated parallel development.

## When to Use

- Spawning isolated environments for parallel agent work
- Working on beads tasks in isolation
- Running multiple Claude instances on different tasks
- Preventing file conflicts between concurrent work

## Commands

| Command | Purpose |
|---------|---------|
| `/jj-workspace create <name>` | Create new workspace for task |
| `/jj-workspace list` | List all workspaces for current project |
| `/jj-workspace switch <name>` | Switch to existing workspace |
| `/jj-workspace merge <name>` | Merge workspace changes back, cleanup |
| `/jj-workspace cleanup` | Remove stale/completed workspaces |
| `/jj-workspace status` | Show workspace status and any conflicts |

## Directory Structure

```
~/.jj-workspaces/
└── <project-name>/           # Derived from current repo name
    ├── <task-id>/            # One workspace per task
    │   ├── .worker.pid       # PID if headless agent running
    │   ├── .worker.log       # Agent output log
    │   └── <project files>   # Working copy
    └── <another-task>/
```

## Operations

### Create Workspace

```bash
# Get project name from current directory
PROJECT_NAME=$(basename $(jj root))
WORKSPACE_PATH=~/.jj-workspaces/$PROJECT_NAME/$TASK_NAME

# Create the workspace
jj workspace add "$WORKSPACE_PATH" --name "$TASK_NAME"

# Navigate to it
cd "$WORKSPACE_PATH"

# Sync beads (import latest task data)
bd sync --import-only
```

### List Workspaces

```bash
# List all jj workspaces
jj workspace list

# List filesystem directories
ls -la ~/.jj-workspaces/$PROJECT_NAME/
```

### Switch to Workspace

```bash
cd ~/.jj-workspaces/$PROJECT_NAME/$TASK_NAME

# Ensure beads are synced
bd sync --import-only

# Check for stale workspace
jj workspace update-stale
```

### Merge Workspace

```bash
# From main workspace (not the task workspace)
cd $(jj root)

# Squash the workspace's changes into a single commit
jj squash --from $TASK_NAME@ -m "completed $TASK_NAME"

# Remove the workspace
jj workspace forget $TASK_NAME

# Clean up filesystem
rm -rf ~/.jj-workspaces/$PROJECT_NAME/$TASK_NAME
```

### Cleanup Stale Workspaces

```bash
# Update any stale workspaces
jj workspace update-stale

# List and remove completed ones
for ws in $(jj workspace list | grep -v default | awk '{print $1}'); do
    # Check if workspace directory exists
    if [ ! -d ~/.jj-workspaces/$PROJECT_NAME/$ws ]; then
        jj workspace forget $ws
    fi
done
```

## Beads Integration

Each workspace shares the same `.beads/issues.jsonl` via the jj store:

```bash
# In new workspace, sync beads from main
bd sync --import-only

# Claim the task
bd update $TASK_ID --status=in_progress

# When done
bd close $TASK_ID
```

## Conflict Handling

When merging workspaces that touched same files:

1. jj marks conflicts in the working copy
2. Use `/conflict-merge` skill to resolve
3. After resolution: `jj resolve --mark <file>`

## Worker Detection

Check if a headless agent is running in a workspace:

```bash
WORKSPACE_PATH=~/.jj-workspaces/$PROJECT_NAME/$TASK_NAME

if [ -f "$WORKSPACE_PATH/.worker.pid" ]; then
    PID=$(cat "$WORKSPACE_PATH/.worker.pid")
    if ps -p $PID > /dev/null 2>&1; then
        echo "Worker running (PID: $PID)"
    else
        echo "Worker stopped (stale PID file)"
        rm "$WORKSPACE_PATH/.worker.pid"
    fi
else
    echo "No worker"
fi
```

## Best Practices

1. **One task per workspace**: Keep workspaces focused on single beads tasks
2. **Sync beads on entry**: Always run `bd sync --import-only` when entering a workspace
3. **Merge promptly**: Don't let workspaces accumulate; merge when task is complete
4. **Check for conflicts**: Before merging, review what files changed with `jj diff`
5. **Use task IDs as names**: Name workspaces after beads task IDs for easy tracking

## Permissions

Ensure `~/.jj-workspaces` is in Claude's `additionalDirectories`:

```json
// ~/.claude/settings.json
{
  "permissions": {
    "additionalDirectories": [
      "~/.jj-workspaces"
    ]
  }
}
```
