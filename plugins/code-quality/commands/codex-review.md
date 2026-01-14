---
name: Codex Review
description: Request independent code review from Codex using shared quality principles.
category: Code Quality
tags: [review, codex, quality]
---

# Codex Code Review

Request an independent code review from Codex for the current changes.

## Process

1. **Generate the diff**
   ```bash
   jj diff --git
   ```

2. **Prepare review context**
   - Load `@principles` skill for quality standards
   - Include the diff output
   - Specify focus areas if applicable

3. **Submit to Codex**

   Use the MCP codex tool with this prompt structure:

   ```
   Review the following code changes against these quality principles:

   ## Quality Principles (@principles)

   Architecture:
   - Imperative shell, functional core (pure functions + thin I/O layer)

   Design:
   - Make illegal states unrepresentable (discriminated unions over boolean flags)
   - Single responsibility (one reason to change per unit)
   - Open-closed (open for extension, closed for modification)
   - Parse, don't validate (validated types at boundaries)
   - Prefer composition over inheritance
   - Make dependencies explicit (no hidden globals)
   - Fail fast and loudly (surface errors immediately)
   - Domain errors (errors should be identifiable for action)
   - Prefer immutability (const/readonly by default)
   - Avoid stringly-typed code (unions/enums over magic strings)
   - Left-hand side is the happy path (early returns, reduce nesting)

   Standards:
   - Clarity over brevity
   - No lint suppressions without explicit approval
   - No workarounds—fix root causes

   ## Code Diff

   [Insert jj diff --git output here]

   ## Review Request

   Identify any violations of the above principles. For each issue:
   1. Quote the problematic code
   2. State which principle is violated
   3. Suggest a specific fix

   If the code adheres to all principles, state "No issues found."
   ```

4. **Address findings**
   - Fix issues identified by Codex
   - Re-run review if significant changes were made
