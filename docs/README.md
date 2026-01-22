# Isometrik Chat Flutter SDK - Documentation

**Last Updated:** January 21, 2026

## Overview

This directory contains comprehensive documentation for the Isometrik Chat Flutter SDK, organized by module and topic.

## Documentation Files

### Architecture & Design

- **[ARCHITECTURE.md](../ARCHITECTURE.md)** - Complete architecture documentation
  - Overview and principles
  - Design patterns
  - Module structure
  - Data flow diagrams
  - Key architectural decisions

- **[ARCHITECTURAL_DIAGRAMS.md](./ARCHITECTURAL_DIAGRAMS.md)** - Visual architectural diagrams
  - System architecture overview
  - Component relationships
  - Data flow sequences
  - Module dependencies
  - Controller composition
  - MQTT event processing
  - State management flow

### Module Documentation

- **[MODULE_CONTROLLERS.md](./MODULE_CONTROLLERS.md)** - Controllers module
  - GetX controllers
  - Mixin organization
  - State management
  - Lifecycle

- **[MODULE_MODELS.md](./MODULE_MODELS.md)** - Models module
  - Data models
  - Serialization
  - Key model structures

- **[MODULE_REPOSITORIES.md](./MODULE_REPOSITORIES.md)** - Repositories module
  - Data access abstraction
  - Repository pattern
  - API and database access

- **[MODULE_VIEWS.md](./MODULE_VIEWS.md)** - Views module
  - UI screens
  - Navigation
  - Widget composition

- **[MODULE_WIDGETS.md](./MODULE_WIDGETS.md)** - Widgets module
  - Reusable components
  - Custom widgets
  - Widget categories

- **[MODULE_UTILITIES.md](./MODULE_UTILITIES.md)** - Utilities module
  - Helper functions
  - Extensions
  - Logging
  - Debouncing

- **[MODULE_DATA.md](./MODULE_DATA.md)** - Data module
  - Network layer
  - Database layer
  - API endpoints
  - Data flow

### Feature & Issue Tracking

- **[FEATURES.md](./FEATURES.md)** - Feature list and status
  - 21 core features documented
  - Platform compatibility matrix
  - Known limitations
  - Feature flags

- **[KNOWN_ISSUES.md](./KNOWN_ISSUES.md)** - Known issues and workarounds
  - Issue status tracking
  - Platform-specific issues
  - Workarounds and fixes
  - Reporting guidelines

- **[ROADMAP.md](./ROADMAP.md)** - Feature roadmap
  - Planned features by quarter (Q1-Q4 2026)
  - Long-term goals (2027+)
  - Version history
  - Priority levels

### Reports

- **[SDK_PROTOCOL_REPORT.md](../SDK_PROTOCOL_REPORT.md)** - SDK protocol and status report

## Quick Start

1. **New to the SDK?** Start with [ARCHITECTURE.md](../ARCHITECTURE.md)
2. **Working with controllers?** See [MODULE_CONTROLLERS.md](./MODULE_CONTROLLERS.md)
3. **Need to understand data flow?** See [ARCHITECTURE.md](../ARCHITECTURE.md#data-flow)
4. **Looking for API endpoints?** See [MODULE_DATA.md](./MODULE_DATA.md)

## Documentation Standards

All documentation follows these standards:

- **Clear structure** with table of contents
- **Code examples** for common use cases
- **Cross-references** to related documentation
- **Last updated** dates for tracking changes
- **See Also** sections for related topics

## Contributing

When adding new features or modules:

1. Update relevant module documentation
2. Add inline documentation to code
3. Update architecture documentation if structure changes
4. Add examples for new APIs

## Related Resources

- [Main README](../README.md) - SDK overview and setup
- [CHANGELOG.md](../CHANGELOG.md) - Version history
- [ARCHITECTURE.md](../ARCHITECTURE.md) - Complete architecture guide

