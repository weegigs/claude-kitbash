# ByteRover Examples

## Query Patterns

### Domain Knowledge
```bash
brv query "What is the invoice format?"
brv query "How does the permissions system work?"
```

### Lessons Learned
```bash
brv query "What bugs have been found in the PDF converter?"
brv query "What issues exist with the caching layer?"
```

### Format Specifications
```bash
brv query "What fields does the user profile have?"
```

## Curate Patterns

### Bug Investigation
```bash
brv curate "PDF converter bug: images not extracted from embedded resources. Converter only processes top-level assets, but some PDFs store images in nested resource dictionaries. Fix: Add recursive resource extraction." -f crates/pdf/src/extractor.rs
```

### Domain Knowledge
```bash
brv curate "Two permission models coexist: legacy uses role-based (admin/user/guest), new system uses capability-based (granular permissions). Migration in progress - check user.permission_version to determine which applies."
```

### Architectural Decision
```bash
brv curate "Cache invalidation strategy: write-through for user data (consistency critical), write-behind for analytics (eventual consistency acceptable). Chose this split to balance latency vs accuracy requirements." -f crates/cache/src/strategy.rs
```

## When to Curate

**Curate when:**
- Investigation took significant effort
- Knowledge is project-specific
- Decision has non-obvious rationale
- Gotcha would save future time

**Skip when:**
- Information obvious from code
- Change is trivial
- General programming knowledge
- Temporary debugging
