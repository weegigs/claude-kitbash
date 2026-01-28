# Changelog

## [1.1.0] - 2026-01-28

### Added
- `search:deep-research` skill for multi-step investigation workflows
- `search:verify` skill for source verification and fact-checking
- `search:plan` skill for research planning before execution
- Progressive enhancement model with 4 escalation levels
- Output format templates for structured findings
- Integration tables showing skill workflow phases
- Proactive verification triggers for high-stakes research

### Changed
- `search:patterns` now canonical reference for progressive enhancement
- Other skills reference patterns.md instead of duplicating content
- Tool selection guide reorganized by need (quick → complex)
- All code blocks now have language hints for consistency

## [1.0.0] - 2026-01-15

### Added
- Initial release
- `search:` main skill with tool selection guide
- `search:patterns` for query construction best practices
- `search:context7` for library documentation patterns
- `search:perplexity` for deep research workflows
- Date guard hook to prevent stale search results
- MCP availability checks with WebSearch fallback
