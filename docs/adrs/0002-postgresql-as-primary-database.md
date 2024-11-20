# 2. PostgreSQL as Primary Database

* Status: accepted
* Deciders: Platform Engineering Team, DevOps Team
* Date: 2024-03-20
* Technical Story: Need for a reliable database solution for Backstage

## Context and Problem Statement

What database solution should we use for storing Backstage's catalog information, user data, plugin data, and search indices? We need a solution that provides reliability, performance, and good integration with Backstage.

## Decision Drivers

* Data consistency requirements
* Search capabilities
* Integration with Backstage
* Team expertise
* Operational overhead
* Scalability needs

## Considered Options

* PostgreSQL
* MySQL
* SQLite
* MongoDB

## Decision Outcome

Chosen option: "PostgreSQL", because it provides the best combination of native Backstage support, reliability, and team expertise.

### Positive Consequences

* Native support in Backstage ecosystem
* Built-in full-text search capabilities
* Strong data consistency guarantees
* Familiar to the team
* Rich ecosystem of tools

### Negative Consequences

* Requires dedicated database management
* Need for connection pooling setup
* Storage costs for large deployments
* Regular maintenance required

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

## Links

* [Backstage Database Documentation](https://backstage.io/docs/tutorials/database-management)
* [PostgreSQL Documentation](https://www.postgresql.org/docs/)
* [ADR-0004](0004-kubernetes-deployment.md) - Related deployment considerations