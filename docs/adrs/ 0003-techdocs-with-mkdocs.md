# 3. TechDocs with MkDocs

Date: 2024-03-20

## Status
Accepted

## Context
Documentation is crucial for our services, and we needed a solution that:
- Supports Markdown
- Can be version controlled
- Provides good rendering
- Easy to maintain

## Decision
We chose to use TechDocs with MkDocs because:
- Native Backstage integration
- Markdown-based
- Supports code highlighting
- Extensible through plugins
- Can be stored alongside code

## Consequences
### Positive
- Documentation as code
- Version controlled docs
- Rich formatting options
- Easy to write and maintain

### Negative
- Additional build step required
- Storage needed for generated docs
- Learning curve for advanced features