# 1. Use Backstage as Developer Portal

* Status: accepted
* Deciders: Platform Engineering Team
* Date: 2024-03-20
* Technical Story: Need for a centralized developer portal platform

## Context and Problem Statement

How can we provide a unified developer experience with service catalog, documentation, and tooling integration capabilities? We need a solution that supports our microservices architecture and enables efficient developer workflows.

## Decision Drivers

* Need for centralized service catalog
* Documentation-as-code requirements
* Tool integration capabilities
* Developer experience
* Extensibility and customization options

## Considered Options

* Backstage
* Custom-built solution
* Other developer portals (e.g., Port, OpsLevel)

## Decision Outcome

Chosen option: "Backstage", because it provides the best balance of features, extensibility, and community support.

### Positive Consequences

* Unified developer experience through a single platform
* Rich plugin ecosystem for tool integration
* Documentation-as-code with TechDocs
* Service catalog with automatic discovery
* Template-based service scaffolding

### Negative Consequences

* Learning curve for development team
* Infrastructure maintenance overhead
* Need for custom plugin development
* Resource requirements for hosting

## Pros and Cons of the Options

### Backstage

* Good, because it's open source and backed by Spotify
* Good, because it has a growing ecosystem of plugins
* Good, because it supports custom plugin development
* Good, because it uses modern tech stack (React, Node.js, TypeScript)
* Bad, because it requires infrastructure maintenance
* Bad, because it has a learning curve

### Custom-built Solution

* Good, because it could be tailored to our exact needs
* Good, because we would have full control over features
* Bad, because it would require significant development effort
* Bad, because we would need to maintain everything ourselves
* Bad, because we would miss out on community contributions

### Other Developer Portals

* Good, because they offer managed solutions
* Good, because they have built-in features
* Bad, because they are often expensive
* Bad, because they have limited customization options
* Bad, because they might lock us into their ecosystem

## Links

* [Backstage Documentation](https://backstage.io/docs)
* [ADR-0003](0003-techdocs-with-mkdocs.md) - Related decision about documentation