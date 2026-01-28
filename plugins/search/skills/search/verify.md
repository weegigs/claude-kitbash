# Source Verification

Fact-checking and validation patterns for critical information.

## When to Use

- Critical decisions based on search results
- Conflicting information from sources
- Unfamiliar or suspicious claims
- High-stakes technical choices

**Auto-invoke verification when:**
- Research will influence architecture decisions
- Claims contradict known project context or official docs
- Single source provides pivotal information
- Information will be used in production code

## Parallel Verification Pattern

For critical claims, verify from independent angles:

```python
# In parallel (single message, multiple tool calls):
WebSearch("claim X official documentation")
WebSearch("claim X alternative perspective")
perplexity_ask("Is claim X accurate? What are the caveats?")
```

## Verification Checklist

- [ ] Multiple independent sources agree
- [ ] Sources are authoritative for the domain
- [ ] Information is current (check dates)
- [ ] No obvious bias or commercial interest
- [ ] Technical claims are testable

## Red Flags

- Single source only
- No dates or version info
- Marketing language in technical content
- Contradicts official documentation
- AI-generated content without citations
- Circular references (sources citing each other)
- "Works for me" without reproduction steps

## Authoritative Source Hierarchy

Ranked from most to least reliable:

1. **Official documentation** (highest)
2. **Source code / implementation**
3. **Primary research / RFCs / specs**
4. **Reputable tech publications** (with bylines)
5. **Community consensus** (Stack Overflow accepted answers, forum threads)
6. **Individual blogs** (lowest - verify elsewhere)

## Source Quality Assessment

### High Quality Indicators
- Author with verifiable credentials
- Links to primary sources
- Code examples that can be tested
- Published date visible
- Acknowledges limitations/edge cases

### Low Quality Indicators
- No author attribution
- No external references
- Overly promotional tone
- Absolute claims ("always", "never", "best")
- No dates, no version numbers

## Verification Workflow

1. **Identify claim** to verify
2. **Find primary source** (official docs, source code)
3. **Cross-reference** with 2+ independent sources
4. **Check recency** - is this still accurate?
5. **Test if possible** - run the code, check the API
6. **Document confidence level**

## Confidence Levels

Report your confidence when presenting verified information:

| Level | Meaning |
|-------|---------|
| **High** | Multiple authoritative sources agree, tested/testable |
| **Medium** | 2+ sources agree, but not all authoritative |
| **Low** | Single source, or conflicting information |
| **Unverified** | Unable to find corroborating sources |

## Reporting Conflicts

When sources disagree, document the conflict:

```
## Conflicting Information

**Claim**: "Tauri v2 requires Rust 1.70+"

**Source A** (Official docs): States Rust 1.75+ required
**Source B** (Tutorial): Shows examples with Rust 1.70
**Source C** (GitHub issue): Confirms 1.75+ after update

**Resolution**: Trust official docs (Source A), tutorial is outdated.
```

## Detecting Outdated Information

Signs information may be stale:

- Version numbers don't match current releases
- API names/signatures have changed
- Links to deprecated documentation
- Comments mentioning "this no longer works"
- Publication date > 1 year for fast-moving tech

## Quick Verification (Inline)

For lower-stakes claims, verify inline without full workflow:

```python
# Quick check: Does claim match official docs?
Context7.get_library_docs(topic="claimed feature")
# If matches → proceed
# If contradicts → flag for full verification
```

## Verification Depth by Stakes

| Stakes | Verification Level | Actions |
|--------|-------------------|---------|
| Low | Quick inline | One source check |
| Medium | Standard | 2 sources + recency check |
| High | Full workflow | Parallel verification + testing |
| Critical | Exhaustive | All sources + user confirmation |

## Integration with Research

Call verification proactively during research:

```python
# In deep-research workflow:
finding = perplexity_ask("How does X work?")

# Auto-verify if:
if finding.confidence < "high" or finding.affects_architecture:
    invoke("search:verify", claim=finding.key_claim)
```

## Output Format

```markdown
## Verification: [Claim]

**Claim**: "[Exact claim being verified]"
**Verdict**: Verified / Partially Verified / Disputed / Unverified

### Evidence

| Source | Says | Confidence |
|--------|------|------------|
| Official docs | [Quote/summary] | High |
| Source code | [Evidence] | High |
| Community | [Consensus] | Medium |

### Resolution
[Final determination with reasoning]
```
