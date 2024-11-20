---
parent: Architectural Decisions
nav_order: 2
---
* Status: accepted
* Deciders: Platform Engineering Team
* Date: 2024-03-20
* Technical Story: Need for a centralized developer portal platform

# Use PostgreSQL as Primary Database

## Context and Problem Statement

What database solution should we use for storing Backstage's catalog information, user data, plugin data, and search indices?
How can we ensure reliable performance and good integration with Backstage?

## Considered Options

* PostgreSQL
* MySQL
* SQLite
* MongoDB

## Decision Outcome

Chosen option: "PostgreSQL", because it provides the best combination of native Backstage support, reliability, and team expertise.

### Consequences

* Good, because it has native support in Backstage ecosystem
* Good, because it provides built-in full-text search capabilities
* Good, because it ensures strong data consistency guarantees
* Good, because it's familiar to the team
* Good, because it has rich ecosystem of tools
* Bad, because it requires dedicated database management
* Bad, because it needs connection pooling setup
* Bad, because it has storage costs for large deployments
* Bad, because it requires regular maintenance

## Pros and Cons of the Options

### PostgreSQL

* Good, because it has native Backstage support
* Good, because it provides full-text search
* Good, because it has strong ACID compliance
* Good, because team has expertise
* Bad, because it requires dedicated management
* Bad, because it has higher resource requirements

### MySQL

* Good, because it's widely used
* Good, because it's easy to set up
* Bad, because it has limited Backstage integration
* Bad, because it lacks some PostgreSQL features
* Bad, because team lacks deep expertise

### SQLite

* Good, because it's simple to set up
* Good, because it requires no separate server
* Bad, because it's not suitable for production
* Bad, because it lacks scalability
* Bad, because it has limited concurrent access

### MongoDB

* Good, because it's flexible with data structures
* Good, because it scales horizontally
* Bad, because it lacks Backstage integration
* Bad, because it has eventual consistency
* Bad, because team lacks NoSQL expertise

## More Information

* [Backstage Database Documentation](https://backstage.io/docs/tutorials/database-management)
* [PostgreSQL Documentation](https://www.postgresql.org/docs/)
* [ADR-0004](0004-kubernetes-deployment.md) - Related deployment considerations