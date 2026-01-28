# Standards Resolution Order

When injecting or resolving standards, files are looked up in this order:

1. **Project standards first** — Check `.agent-os/standards/project/{path}`
2. **Baseline fallback** — If not in project, check `.agent-os/standards/baseline/{path}`

Project files shadow baseline files at the same path. This allows projects to override profile defaults while inheriting the rest.

## Example

Given:
```
.agent-os/standards/
├── baseline/
│   └── rust/
│       └── error-handling.md    # Profile default
└── project/
    └── rust/
        └── error-handling.md    # Project override
```

When requesting `rust/error-handling`, the **project version** is used because it shadows the baseline.

## @baseline Reference

Project standards can reference baseline content to extend rather than replace:

```markdown
# Error Handling (Project Override)

@baseline(rust/error-handling)

## Project Additions

Our additional error variants...
```

When injecting, `@baseline(path)` is expanded by reading the baseline file at that path.

## Use Cases

| Scenario | Approach |
|----------|----------|
| Use profile as-is | No project file needed, baseline is used |
| Completely replace | Create project file, don't use @baseline |
| Extend profile | Create project file with @baseline + additions |
