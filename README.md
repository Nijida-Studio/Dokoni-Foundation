# Dokoni Foundation

Dokoni Foundation contains reusable libraries for applications in the Dokoni
ecosystem.

The repository is organized by library rather than by implementation language.
Each library owns a platform-neutral Swift core and may add platform adapters,
interop bindings, and optional reusable SwiftUI or Avalonia integration modules.
Application-specific screens, navigation, and workflows remain in their owning
application repositories.

## Initial modules

- **LocalSettings** reads, writes, migrates, and manages settings that belong to
  the local installation.
- **ServiceAccess** models and manages access to local, LAN, and WAN services.
  GitHub, WebDAV, CalDAV, and SMB are example service adapters.
- **DataDistribution** coordinates distribution of settings and user data,
  including synchronization across one user's devices and explicit sharing
  with other people or a family.

## Repository structure

```text
docs/
  architecture.md
  modules.md
src/
  LocalSettings/
  ServiceAccess/
  DataDistribution/
```

Each module is self-contained. Its future source layout may include a portable
Swift core plus explicit platform, UI-integration, interop, test, and build
areas. Swift is the default implementation language for shared behavior on all
supported platforms. .NET code is added where managed bindings or Avalonia UI
integration require it; it is not a separate parallel implementation root.

## Core and UI boundary

A module's core must not depend on SwiftUI, Avalonia, or an application.
Optional reusable UI integration may live beside the core in a separate target
and depend on it. UI integration must remain optional, must not contain a
complete application workflow, and must satisfy the same multi-application
admission rule as every other Foundation capability.

## Module admission rule

A library or optional integration belongs in Dokoni Foundation when at least
two Dokoni ecosystem applications need it and it can remain independent of
their product-specific workflows.

Code needed by only one application stays in that application's repository.
General-purpose third-party libraries remain external dependencies rather than
being copied into this repository.

## Documentation and website

- Architecture: [`docs/architecture.md`](docs/architecture.md)
- Module catalog: [`docs/modules.md`](docs/modules.md)
- Project website: <https://foundation.nijida.de>

Maintained source and project documentation live on `main`. The website is
maintained separately on `gh_pages`.
