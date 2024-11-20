# 3. TechDocs with MkDocs

* Status: accepted
* Deciders: Platform Engineering Team
* Date: 2024-03-20
* Technical Story: Need for a documentation solution that integrates with code

## Context and Problem Statement

How can we provide a documentation solution that supports version control, is easy to maintain, and integrates well with our development workflow? We need a solution that developers will actually use and maintain.

## Decision Drivers

* Documentation-as-code requirements
* Integration with Backstage
* Developer experience
* Maintenance overhead
* Rendering capabilities

## Considered Options

* TechDocs with MkDocs
* Confluence
* GitBook
* Custom documentation solution

## Decision Outcome

Chosen option: "TechDocs with MkDocs", because it provides native Backstage integration and supports documentation-as-code workflow.

### Positive Consequences

* Documentation lives with code
* Version controlled documentation
* Markdown-based writing
* Rich formatting and extensions
* Native Backstage integration

### Negative Consequences

* Additional build step in CI/CD
* Storage needed for generated docs
* Learning curve for advanced features
* Maintenance of documentation pipeline

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

## Links

* [TechDocs Documentation](https://backstage.io/docs/features/techdocs/techdocs-overview)
* [MkDocs Documentation](https://www.mkdocs.org/)
* [ADR-0001](0001-use-backstage-as-developer-portal.md) - Related Backstage decision