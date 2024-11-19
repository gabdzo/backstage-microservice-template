# Backstage Frontend

## Overview
The main frontend application for our Backstage deployment.

## Technical Details
* **Type**: Website
* **Lifecycle**: Production
* **Owner**: [Platform Team](../teams/team-platform.md)

## Dependencies
The frontend component depends on:
* [Backstage Backend](./backstage-backend.md)
* [PostgreSQL Database](../resources/postgres-db.md)

## API Integration
Provides the [Frontend API](../apis/frontend-api.md) which includes:
* Catalog entity listing
* Search functionality
* User management

## Documentation
* Source: `github.com/project-slug: example/backstage-frontend`
* Jira Project: P20009535

## Monitoring
* Health endpoint: `/api/health`
* Metrics: Prometheus compatible