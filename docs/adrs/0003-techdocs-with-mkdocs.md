---
parent: Architectural Decisions
nav_order: 3
---
* Status: accepted
* Deciders: Platform Engineering Team
* Date: 2024-03-20
* Technical Story: Need for a centralized developer portal platform

# Use TechDocs with MkDocs

## Context and Problem Statement

How can we provide a documentation solution that supports version control, is easy to maintain, and integrates well with our development workflow?
How can we ensure developers will actually write and maintain documentation?

## Considered Options

* TechDocs with MkDocs
* Confluence
* GitBook
* Custom documentation solution

## Decision Outcome

Chosen option: "TechDocs with MkDocs", because it provides native Backstage integration and supports documentation-as-code workflow.

### Consequences

* Good, because documentation lives with code
* Good, because documentation is version controlled
* Good, because it uses Markdown for writing
* Good, because it provides rich formatting options
* Good, because it has native Backstage integration
* Bad, because it requires additional build step in CI/CD
* Bad, because it needs storage for generated docs
* Bad, because it has learning curve for advanced features
* Bad, because it requires documentation pipeline maintenance

## Pros and Cons of the Options

### TechDocs with MkDocs

* Good, because it's integrated with Backstage
* Good, because it supports Markdown
* Good, because it has version control
* Good, because it has rich plugin ecosystem
* Bad, because it requires additional build step
* Bad, because it needs separate storage solution

### Confluence

* Good, because it's familiar to teams
* Good, because it has rich text editing
* Bad, because it's separate from code
* Bad, because it's hard to version control
* Bad, because it lacks developer-friendly features

### GitBook

* Good, because it has nice UI
* Good, because it supports Markdown
* Bad, because it's a separate platform
* Bad, because it has limited integration options
* Bad, because it has higher costs

### Custom Solution

* Good, because it could be tailored to needs
* Good, because it could have deep integration
* Bad, because it requires development effort
* Bad, because it needs ongoing maintenance
* Bad, because it lacks community support

## More Information

* [TechDocs Documentation](https://backstage.io/docs/features/techdocs/techdocs-overview)
* [MkDocs Documentation](https://www.mkdocs.org/)
* [ADR-0001](0001-use-backstage-as-developer-portal.md) - Related Backstage decision