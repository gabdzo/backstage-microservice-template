# Backend API

## Overview
Internal API for Backstage backend services that provides core functionality for the platform.

## Technical Details
* **Type**: OpenAPI
* **Lifecycle**: Production
* **Owner**: [Platform Team](../teams/team-platform.md)
* **System**: [Development Portal](../systems/development-portal.md)

## Endpoints

### TechDocs
* `GET /api/techdocs`
  * Retrieves documentation content for specified entities
  * Required query parameter: `entityRef`
  * Returns documentation content and metadata

### Scaffolder
* `POST /api/scaffolder/actions`
  * Executes scaffolder actions for template processing
  * Requires action ID and input parameters
  * Returns action execution results

## Integration
* Base URL: `https://backend.example.com/v1`
* Authentication: Required
* Content Type: JSON

## Documentation
* Source: `example/backstage-backend`
