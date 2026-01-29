# Cop-Out Patterns

Patterns that indicate incomplete or deferred work. Used by `/execute` and `/check`.

## Code Patterns to Avoid

| Pattern | Why It's Wrong | What To Do Instead |
|---------|----------------|-------------------|
| `TODO: fix later` | Defers work without commitment | Complete now or ask user |
| `as any` | Bypasses type safety | Fix the types properly |
| `as unknown as` | Type laundering | Fix the types properly |
| `#[allow(...)]` | Masks Rust lint issues | Fix what the lint catches |
| `eslint-disable` | Masks JS/TS lint issues | Fix what the lint catches |
| `@ts-ignore` | Ignores TypeScript errors | Fix the type error |
| `noqa` | Ignores Python linter | Fix the issue |
| `type: ignore` | Ignores mypy | Fix the type issue |
| Empty `catch {}` | Swallows errors silently | Handle or propagate errors |
| `catch (_)` unused | Swallows errors silently | Handle or propagate errors |
| `.skip()` in tests | Hides test failures | Fix or delete the test |
| `#[ignore]` | Skips Rust tests | Fix or delete the test |
| `@pytest.mark.skip` | Skips Python tests | Fix or delete the test |
| `xit(` / `xdescribe(` | Skips JS tests | Fix or delete the test |

## Language Patterns to Avoid

| Statement | Why It's Wrong | What To Do Instead |
|-----------|----------------|-------------------|
| "out of scope" | Unilateral scope reduction | Ask user if they want to defer |
| "for now" | Implies incomplete solution | Make it complete |
| "I noticed X but..." | Discovered work avoidance | Address X or ask user |
| "beyond the scope" | Unilateral scope reduction | Ask user first |
| "we can revisit later" | Deferred commitment | Handle now or get approval |

## Scan Commands

### Deferred work markers
```bash
rg -n "TODO|FIXME|XXX|HACK|PLACEHOLDER|STUB" <files>
```

### Lint suppressions
```bash
rg -n "#\[allow|eslint-disable|@ts-ignore|noqa|type:\s*ignore" <files>
```

### Type bypasses
```bash
rg -n "as any|as unknown as" <files>
```

### Error swallowing
```bash
rg -n "catch\s*\{\s*\}|catch\s*\(_\)" <files>
```

### Skipped tests
```bash
rg -n "\.skip\(|#\[ignore\]|@pytest\.mark\.skip|xit\(|xdescribe\(" <files>
```

## Approval Requirements

| Finding | Verdict | Required Action |
|---------|---------|-----------------|
| TODO with task reference + user approval | PASS | None |
| TODO with task reference, no user approval | **FAIL** | Get approval or complete now |
| TODO without task reference | **FAIL** | Complete now or get approval + create task |
| Explanatory comment (not deferred work) | PASS | None |
| Any lint suppression without user discussion | **FAIL** | Fix the code or get explicit approval |
| Any type bypass | **FAIL** | Fix the types properly |
| Any empty catch | **FAIL** | Handle or propagate errors |
| Any skipped test | **FAIL** | Fix or remove the test |

## Key Principle

**Even tracked deferrals require explicit user approval.** A task reference makes work trackable, but the user must explicitly say "yes, defer that" in the conversation. The agent cannot unilaterally decide to defer work.
