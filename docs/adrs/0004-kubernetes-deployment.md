---
parent: Architectural Decisions
nav_order: 4
---
* Status: accepted
* Deciders: Platform Engineering Team
* Date: 2024-03-20
* Technical Story: Need for a centralized developer portal platform

# Use Kubernetes for Deployment

## Context and Problem Statement

How should we deploy and manage our Backstage instance in production?
How can we ensure scalability, reliability, and ease of management?

## Considered Options

* Kubernetes deployment
* VM-based deployment
* Serverless deployment
* Managed PaaS solution

## Decision Outcome

Chosen option: "Kubernetes deployment", because it provides the best balance of scalability, manageability, and ecosystem integration.

### Positive Consequences

* Container orchestration capabilities
* Automated scaling and failover
* Resource optimization
* Built-in monitoring
* Rolling updates support
* Service discovery

### Negative Consequences

* Kubernetes complexity
* Higher operational overhead
* Resource requirements
* Need for K8s expertise
* Additional infrastructure costs

## Pros and Cons of the Options

### Kubernetes Deployment

* Good, because it provides container orchestration
* Good, because it supports auto-scaling
* Good, because it has built-in monitoring
* Good, because it enables rolling updates
* Bad, because it adds operational complexity
* Bad, because it requires specialized knowledge

### VM-based Deployment

* Good, because it's simpler to understand
* Good, because it's traditional and proven
* Bad, because it lacks container benefits
* Bad, because manual scaling is required
* Bad, because resource utilization is lower

### Serverless Deployment

* Good, because it reduces operational overhead
* Good, because it has automatic scaling
* Bad, because it has cold start issues
* Bad, because it has limited runtime control
* Bad, because it can be more expensive

### Managed PaaS Solution

* Good, because it reduces management overhead
* Good, because it provides built-in features
* Bad, because it's less flexible
* Bad, because it can be expensive
* Bad, because it may have vendor lock-in

## Links

* [Kubernetes Documentation](https://kubernetes.io/docs/)
* [Backstage K8s Deployment Guide](https://backstage.io/docs/deployment/k8s)
* [ADR-0002](0002-postgresql-as-primary-database.md) - Related database decisions