# Init Flow

First-time setup for projects without `.agent-os/` configuration.

## Step 1: Audit Existing Documentation

Scan for existing project documentation:

```bash
# Check common doc locations
cat README.md 2>/dev/null | head -100
ls docs/*.md 2>/dev/null
cat CONTRIBUTING.md 2>/dev/null | head -50
```

Report findings:

```
Found existing documentation:
- README.md (X lines) — [brief summary of content]
- docs/architecture.md — [brief summary]
- CONTRIBUTING.md — [brief summary]

This information will help bootstrap your product docs.
```

## Step 2: Detect Stack

Analyze project to detect technologies:

```bash
# Node/JS/TS
cat package.json 2>/dev/null | jq -r '.dependencies, .devDependencies | keys[]' 2>/dev/null

# Rust
cat Cargo.toml 2>/dev/null

# Python
cat pyproject.toml requirements.txt 2>/dev/null

# Go
cat go.mod 2>/dev/null
```

Map findings to profile suggestions:

| Detected | Suggested Profile |
|----------|-------------------|
| Svelte + Tauri + Rust | tauri-svelte |
| React + Node | (future: react-node) |
| Other | No profile, manual standards |

## Step 3: Suggest Profile

```
Based on your project, I recommend:

Profile: tauri-svelte
- Svelte 5 + SvelteKit 2
- Tauri v2
- Rust 2024 Edition
- Convex backend

Use this profile? (yes / different / none)
```

If "different" → list available profiles
If "none" → skip standards baseline, user will add manually

## Step 4: Create Structure

```bash
mkdir -p .agent-os/product
mkdir -p .agent-os/specs
mkdir -p .agent-os/standards/project
```

## Step 5: Hand Off to Product Planning

```
Agent-os structure created.

Next: Let's establish your product documentation.
```

Delegate to `/plan-product` to create:
- `.agent-os/product/mission.md`
- `.agent-os/product/roadmap.md`
- `.agent-os/product/tech-stack.md`

## Step 6: Initialize Standards

After product planning completes:

```
Product docs created. Now let's set up standards.
```

If profile was selected → delegate to `/standards init`
If no profile → show manual setup instructions:

```
No profile selected. To add standards manually:

1. Create standards in .agent-os/standards/project/
2. Use /standards discover to extract patterns from code
3. Use /standards-inject to apply them to conversations
```

## Step 7: Update CLAUDE.md

Check if CLAUDE.md exists and contains agent-os guidance:

```bash
# Check for existing CLAUDE.md
if [ -f "CLAUDE.md" ]; then
  grep -qi "agent-os\|/spec\|/standards\|/triage" CLAUDE.md && echo "has-guidance" || echo "no-guidance"
else
  echo "missing"
fi
```

**If missing or no guidance:**

```
CLAUDE.md [doesn't exist / exists but lacks agent-os guidance].

Add agent-os section to CLAUDE.md? (yes / no)
```

If yes, add or append:

```markdown
## Agent-OS

This project uses agent-os for standards and specifications.

### Available Skills

| Skill | Purpose |
|-------|---------|
| `/setup` | Initialize or refresh agent-os |
| `/spec` | Create feature/bug/refactor specifications |
| `/triage` | Interactive issue discovery session |
| `/standards` | Manage coding standards |
| `/kick-off` | Create execution plans from specs |

### Workflow

1. **New work**: `/spec <description>` → creates spec in `.agent-os/specs/`
2. **Issue discovery**: `/triage <area>` → capture and evaluate issues
3. **Execution**: `/kick-off` → plan from spec, then `/execute`
4. **Standards**: `/standards-inject` loads relevant standards into context

### Directory Structure

- `.agent-os/product/` — Mission, roadmap, tech stack
- `.agent-os/specs/` — Feature and bug specifications  
- `.agent-os/standards/` — Coding standards (baseline + project)
```

## Step 8: Confirm Completion

```
Setup complete.

Created:
  .agent-os/product/mission.md
  .agent-os/product/roadmap.md
  .agent-os/product/tech-stack.md
  .agent-os/standards/baseline/ (if profile selected)
  CLAUDE.md updated with agent-os guidance (if accepted)

Next steps:
- Review product docs and refine as needed
- Add project-specific standards with /standards discover
- Create specs for features with /spec
```
