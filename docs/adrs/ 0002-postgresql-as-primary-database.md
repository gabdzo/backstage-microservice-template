# 2. PostgreSQL as Primary Database

Date: 2024-03-20

## Status
Accepted

## Context
Backstage requires a database to store:
- Catalog information
- User data
- Plugin-specific data
- Search indices

## Decision
We chose PostgreSQL as our primary database because:
- Native support in Backstage
- Strong consistency guarantees
- Full-text search capabilities
- Mature ecosystem
- Team familiarity

## Consequences
### Positive
- Reliable data storage
- Built-in search capabilities
- Easy backup and restore
- Good performance

### Negative
- Need for database maintenance
- Requires connection pooling setup
- Storage costs for large deployments