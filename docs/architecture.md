# Architecture

## Role in the Dokoni ecosystem

Dokoni Foundation is the shared library layer of the Dokoni ecosystem. It is
organized by capability rather than by implementation language:

```text
Application screens, navigation, and product workflows
                         |
Optional reusable UI integration
          SwiftUI / Avalonia
                         |
Platform hosts, adapters, and .NET bindings
                         |
Platform-neutral Swift core
                         |
Platform SDKs and established third-party libraries
```

Dokoni itself is the central application of the ecosystem, but Foundation is
not part of Dokoni's application-specific core. Foundation libraries must
remain consumable by multiple ecosystem applications independently.

## Ownership boundaries

### Foundation owns

- reusable capabilities required by multiple ecosystem applications,
- platform-neutral contracts and Swift implementations,
- explicit platform adapters,
- interop bindings required to consume Swift modules from .NET,
- optional reusable SwiftUI or Avalonia integration modules,
- cross-application semantics, test fixtures, and compatibility guidance.

### Applications own

- complete screens, navigation, and product-specific interaction,
- application workflows and product decisions,
- libraries and UI integration used by only that application,
- composition of Foundation capabilities into application behavior.

### External dependencies own

- general-purpose functionality that is not specific to the Dokoni ecosystem,
- platform SDKs and established third-party protocols or clients.

Foundation may wrap an external dependency behind a stable ecosystem contract
when multiple applications require the same behavior. It should not duplicate
an external library merely to place it under the Dokoni name.

## Library-first source model

The repository uses one directory per Foundation library under `src/`.
Implementation language is not a top-level organizational boundary.

A library may evolve toward this internal shape when concrete code requires it:

```text
src/<Library>/
  README.md
  Sources/
    Core/
    Platforms/
      Apple/
      Windows/
      Linux/
      Android/
    UI/
      SwiftUI/
      Avalonia/
    Interop/
      CAPI/
      DotNet/
  Tests/
  Build/
    README.md
    apple.md
    windows.md
    linux.md
    android.md
```

These directories are created only when the corresponding implementation
exists. Swift Package Manager targets, C/C++ bridge targets, .NET projects, and
Avalonia control libraries remain separate build units even when they belong to
the same Foundation library.

## Core and UI dependency rule

A library's platform-neutral Swift core must not depend on SwiftUI, Avalonia,
an application, or an application workflow. Platform adapters, bindings, and UI
integration may depend on the core. The dependency direction must never be
reversed.

Reusable UI integration is permitted only as an optional module. It should
provide focused controls, views, presentation models, or embedding adapters. It
must not become a shared copy of an application's navigation or complete user
experience.

## Platform model

Shared behavior is designed in Swift for Apple, Windows, GNU/Linux, and Android.
Platform-specific behavior is isolated in platform targets or directories.
SwiftUI provides Apple UI integration. Avalonia and its managed .NET binding
layer provide UI integration for Windows, GNU/Linux, and Android.

A separate .NET reimplementation is an exception rather than the default.
Equivalent behavior implemented more than once must follow shared documented
semantics and contract tests.

When a capability spans platforms, its module documentation should define:

- responsibility and non-goals,
- public concepts and behavior,
- error and cancellation semantics,
- data ownership, credentials, privacy, and sharing expectations,
- platform-specific deviations,
- compatibility and versioning expectations,
- general build steps and platform-specific build additions.

## Initial dependency direction

```text
DataDistribution
  ├──> LocalSettings
  └──> ServiceAccess

ServiceAccess
  └──> LocalSettings (non-secret connection metadata only)

LocalSettings
  └──> no other Foundation module
```

Credentials and secrets are not ordinary settings. ServiceAccess refers to
secure platform credential storage through an explicit abstraction.

## Module lifecycle

1. Record at least two intended consumers.
2. Define the capability boundary and public contract.
3. Define core, platform, binding, and optional UI targets.
4. Add tests before or alongside implementation where technically possible.
5. Document general and platform-specific build requirements.
6. Version and release modules so applications can update deliberately.

Moving an existing app-specific library or UI component into Foundation
requires an explicit contract review. Source code should not be copied merely
because a second consumer appears.
