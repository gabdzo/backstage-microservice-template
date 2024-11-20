---
parent: Architectural Decisions
nav_order: 1
---
# Use Backstage as Developer Portal

## Context and Problem Statement

How can we provide a unified developer experience with service catalog, documentation, and tooling integration capabilities?
How can we ensure efficient developer workflows in our microservices architecture?

## Considered Options

* Backstage
* Custom-built solution
* Other developer portals (e.g., Port, OpsLevel)

## Decision Outcome

Chosen option: "Backstage", because it provides the best balance of features, extensibility, and community support.

### Consequences

* Good, because it provides unified developer experience through a single platform
* Good, because it offers rich plugin ecosystem for tool integration
* Good, because it supports documentation-as-code with TechDocs
* Good, because it enables service catalog with automatic discovery
* Good, because it provides template-based service scaffolding
* Bad, because it has learning curve for development team
* Bad, because it requires infrastructure maintenance overhead
* Bad, because it needs custom plugin development
* Bad, because it has resource requirements for hosting

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

## More Information

* [Backstage Documentation](https://backstage.io/docs)
* [ADR-0003](0003-techdocs-with-mkdocs.md) - Related decision about documentation