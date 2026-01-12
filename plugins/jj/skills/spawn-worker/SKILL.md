---
name: spawn-worker
description: Spawn headless Claude agents in isolated jj workspaces to work on beads tasks. Use when delegating tasks to parallel workers.
---

# spawn-worker Skill

Spawn headless Claude agents in isolated jj workspaces to work on beads tasks.

## When to Use

- Delegating beads tasks to parallel worker agents
- Running multiple Claude instances on independent tasks
- Automating task execution with dependency ordering
- Building agent clusters for large refactors

## Commands

| Command | Purpose |
|---------|---------|
| `/spawn-worker <task-id>` | Create workspace + spawn agent for specific task |
| `/spawn-worker --ready` | Spawn workers for all `bd ready` tasks (up to limit) |
| `/spawn-worker --status` | Check status of all running workers |
| `/spawn-worker --kill <task-id>` | Terminate a worker by task ID |
| `/spawn-worker --logs <task-id>` | View worker output log |

## Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| Max workers | 3 | Maximum concurrent workers |
| Allowed tools | Read,Edit,Bash,Write | Tools worker can use |
| Output format | stream-json | Claude CLI output format |

## Spawning a Single Worker

```bash
PROJECT_NAME=$(basename $(jj root))
TASK_ID="$1"
WORKSPACE_PATH=~/.jj-workspaces/$PROJECT_NAME/$TASK_ID

# 1. Create workspace
jj workspace add "$WORKSPACE_PATH" --name "$TASK_ID"

# 2. Sync beads in new workspace
cd "$WORKSPACE_PATH"
bd sync --import-only

# 3. Claim the task
bd update "$TASK_ID" --status=in_progress --assignee="worker-$TASK_ID"

# 4. Spawn headless Claude
claude -p "You are a worker agent assigned to beads task $TASK_ID.

## Your Task
Run 'bd show $TASK_ID' to see the full task description and requirements.

## Constraints
- Work ONLY in this workspace: $WORKSPACE_PATH
- Do NOT modify files outside this directory
- Do NOT spawn additional workers

## Completion Protocol
1. Implement the task requirements
2. Run any tests if applicable
3. When complete, run: bd close $TASK_ID --reason=\"Implemented\"
4. Exit cleanly

## If Blocked
If you encounter blockers, run:
  bd update $TASK_ID --status=blocked --notes=\"<reason>\"
Then exit." \
  --allowedTools "Read,Edit,Bash,Write" \
  --output-format stream-json \
  > "$WORKSPACE_PATH/.worker.log" 2>&1 &

# 5. Save PID
echo $! > "$WORKSPACE_PATH/.worker.pid"
echo "Spawned worker for $TASK_ID (PID: $!)"
```

## Spawning Workers for Ready Tasks

```bash
PROJECT_NAME=$(basename $(jj root))
MAX_WORKERS=3

# Count current workers
CURRENT=$(find ~/.jj-workspaces/$PROJECT_NAME -name ".worker.pid" -exec sh -c 'ps -p $(cat {}) > /dev/null 2>&1 && echo 1' \; | wc -l)

# Get ready tasks
READY_TASKS=$(bd ready --json | jq -r '.[].id')

for TASK_ID in $READY_TASKS; do
    if [ $CURRENT -ge $MAX_WORKERS ]; then
        echo "Max workers ($MAX_WORKERS) reached, skipping $TASK_ID"
        break
    fi

    # Check if already running
    WORKSPACE_PATH=~/.jj-workspaces/$PROJECT_NAME/$TASK_ID
    if [ -f "$WORKSPACE_PATH/.worker.pid" ]; then
        PID=$(cat "$WORKSPACE_PATH/.worker.pid")
        if ps -p $PID > /dev/null 2>&1; then
            echo "Worker already running for $TASK_ID"
            continue
        fi
    fi

    # Spawn worker (using single-task spawn logic above)
    /spawn-worker $TASK_ID
    CURRENT=$((CURRENT + 1))
done
```

## Checking Worker Status

```bash
PROJECT_NAME=$(basename $(jj root))

echo "=== Worker Status ==="
for ws_path in ~/.jj-workspaces/$PROJECT_NAME/*/; do
    TASK_ID=$(basename "$ws_path")
    PID_FILE="$ws_path/.worker.pid"

    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p $PID > /dev/null 2>&1; then
            STATUS="RUNNING (PID: $PID)"
        else
            STATUS="STOPPED (stale PID)"
        fi
    else
        STATUS="NO WORKER"
    fi

    # Get beads task status
    BEADS_STATUS=$(bd show "$TASK_ID" --json 2>/dev/null | jq -r '.status // "unknown"')

    echo "$TASK_ID: $STATUS | beads: $BEADS_STATUS"
done
```

## Viewing Worker Logs

```bash
PROJECT_NAME=$(basename $(jj root))
TASK_ID="$1"
WORKSPACE_PATH=~/.jj-workspaces/$PROJECT_NAME/$TASK_ID

# Stream the log
tail -f "$WORKSPACE_PATH/.worker.log"

# Or view last N lines
tail -100 "$WORKSPACE_PATH/.worker.log"
```

## Killing a Worker

```bash
PROJECT_NAME=$(basename $(jj root))
TASK_ID="$1"
WORKSPACE_PATH=~/.jj-workspaces/$PROJECT_NAME/$TASK_ID

if [ -f "$WORKSPACE_PATH/.worker.pid" ]; then
    PID=$(cat "$WORKSPACE_PATH/.worker.pid")
    kill $PID 2>/dev/null && echo "Killed worker $TASK_ID (PID: $PID)"
    rm "$WORKSPACE_PATH/.worker.pid"
else
    echo "No worker found for $TASK_ID"
fi
```

## Worker System Prompt Template

The worker agent receives this context:

```
You are a worker agent assigned to beads task {TASK_ID}.

## Your Task
Run 'bd show {TASK_ID}' to see the full task description.

## Workspace
- Root: {WORKSPACE_PATH}
- Project: {PROJECT_NAME}

## Beads Commands
- bd show {TASK_ID}     # View task details
- bd update {TASK_ID}   # Update status/notes
- bd close {TASK_ID}    # Mark complete

## Completion Protocol
1. Implement the requirements
2. Run tests if applicable
3. Close the task: bd close {TASK_ID}
4. Exit cleanly

## If Blocked
Update status and exit:
  bd update {TASK_ID} --status=blocked --notes="<reason>"
```

## Allowed Tools

Workers are spawned with limited tool access:

| Tool | Purpose |
|------|---------|
| Read | Read files in workspace |
| Edit | Modify files in workspace |
| Write | Create new files |
| Bash | Run commands (builds, tests) |

Tools NOT allowed by default:
- Task (no spawning sub-agents)
- WebSearch / WebFetch (focus on local work)

## Best Practices

1. **Limit concurrency**: Start with 2-3 workers to monitor behavior
2. **Monitor logs**: Use `/spawn-worker --status` regularly
3. **Clean up**: Merge completed workspaces promptly
4. **Task design**: Ensure tasks are independent to avoid conflicts
5. **Dependency ordering**: Let beads handle dependencies via `bd ready`

## Error Handling

If a worker fails:

1. Check the log: `tail ~/.jj-workspaces/$PROJECT/$TASK/.worker.log`
2. Check beads status: `bd show $TASK`
3. Options:
   - Respawn: `/spawn-worker $TASK`
   - Mark blocked: `bd update $TASK --status=blocked`
   - Reopen and reassign: `bd reopen $TASK`
