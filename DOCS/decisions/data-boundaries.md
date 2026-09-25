# Data layer boundaries

- Status: Current
- Scope: Main app presentation, domain use cases, and data adapters.

## Constraint

Keep application behavior divided between UI-facing presentation and app coordination, domain use cases and repository protocols, and data-source/repository implementations. Domain protocols define the operations consumed by use cases; the Data layer implements those operations. `AppIntent` is the current composition and coordination point that wires concrete data sources and use cases into the app flow.

Changes that introduce a new persistence or remote-data path should follow the existing boundary or update this decision and [the architecture overview](../architecture.md) together. Do not move storage- or transport-specific work into SwiftUI views or domain models.

This page records the current structural constraint visible in code. The repository does not contain a historical design rationale for this boundary.
