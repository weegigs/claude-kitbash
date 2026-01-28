# Audit Mode

Report-only mode that shows what would be done without making changes.

## Usage

```
/setup audit
```

## Process

Runs the same drift detection as Refresh Flow but outputs a read-only report:

```
Audit Report (no changes made)
==============================

Project State:
- Agent-os configured: yes
- Product docs: 3 files
- Standards baseline: tauri-svelte@1.0.0
- Project standards: 2 files
- Specs: 5 files

Drift Detected:
- README modified after product docs (would update mission.md)
- 2 new dependencies (would update tech-stack.md)
- Baseline outdated by 1 version (would update to 1.1.0)
- 3 undocumented code patterns (would suggest standards)

Run /setup refresh to apply updates.
```

## When to Use

- Before major releases to check documentation health
- During code reviews to validate configuration state
- As part of CI/CD to detect configuration drift
- When onboarding to understand project setup status
