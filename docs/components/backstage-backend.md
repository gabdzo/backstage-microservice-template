# Backstage Backend

## Overview
The backend service component of our Backstage deployment that provides core platform functionality.

## Technical Details
* **Type**: Service
* **Lifecycle**: Production
* **Owner**: [Platform Team](../teams/team-platform.md)

## Dependencies
The backend component depends on:
* [PostgreSQL Database](../resources/postgres-db.md)
* [Redis Cache](../resources/redis-cache.md)

## Features
* TechDocs generation and serving
* Scaffolder actions execution
* Authentication and authorization
* Catalog management
* Search indexing

## API Integration
Provides the [Backend API](../apis/backend-api.md) which includes:
* TechDocs API
* Scaffolder API
* Authentication endpoints

## Documentation
* Source: `github.com/project-slug: example/backstage-backend`
* Development Guide: See [README](../../packages/backend/README.md)

## Configuration
* Default port: 7007
* Database: PostgreSQL (production) / SQLite (development)
* Authentication: Supports GitHub and guest authentication
