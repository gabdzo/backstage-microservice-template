# Frontend API

## Overview
API for frontend services of the Backstage portal that provides catalog and search functionality.

## Technical Details
* **Type**: OpenAPI
* **Lifecycle**: Production
* **Owner**: [Platform Team](../teams/team-platform.md)
* **System**: [Development Portal](../systems/development-portal.md)

## Endpoints

### Catalog
* `GET /api/catalog`
  * Lists catalog entities
  * Optional query parameters:
    * `kind`: Filter by entity kind
    * `filter`: Custom filter string

### Search
* `POST /api/search`
  * Performs search across all entities
  * Request body:
    * `term`: Search term
    * `filters`: Optional search filters
  * Returns paginated search results

## Integration
* Base URL: `https://api.example.com/v1`
* Authentication: Required
* Content Type: JSON

## Documentation
* Source: `example/backstage-frontend`
