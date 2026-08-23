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

## Ownership boundaries

Foundation owns reusable capabilities required by multiple ecosystem
applications, their platform-neutral contracts and Swift implementations,
explicit adapters, bindings, and optional reusable UI integration.

Applications retain complete screens, navigation, product workflows, and
libraries or UI needed by only one application.

## Library-first source model

The repository uses one directory per Foundation library under `src/`.
Implementation language is not a top-level organizational boundary.

The first concrete structure is intentionally small:

```text
src/<Library>/
  README.md
  API/
  Models/
  Store/
```

- `Models/` describes the data owned by the module.
- `Store/` contains storage or management responsibilities owned by the module.
- `API/` describes the interface through which other modules use it.

Platform, UI, binding, test, and build areas are added later when concrete code
requires them. Build-system target boundaries may refine this logical layout
without changing module ownership.

## Data and settings boundary

DataStorage reads and writes opaque data. It does not understand, decode, or
modify the content semantically.

LocalSettings owns the settings format and behavior:

```text
DataStorage reads bytes
        |
LocalSettings decodes, modifies, and encodes settings
        |
DataStorage writes the resulting bytes
```

This keeps persistence locations independent from settings models and formats.

## Core and UI dependency rule

A platform-neutral core must not depend on SwiftUI, Avalonia, an application,
or an application workflow. Platform adapters, bindings, and optional UI
integration may depend on the core. The dependency direction must never be
reversed.

## Platform model

Shared behavior is designed in Swift for Apple, Windows, GNU/Linux, and Android.
SwiftUI provides Apple UI integration. Avalonia and its managed .NET binding
layer provide UI integration for Windows, GNU/Linux, and Android.

A separate .NET reimplementation is an exception rather than the default.

## Initial dependency direction

```text
DataDistribution
  ├──> LocalSettings
  └──> ServiceAccess

ServiceAccess
  └──> LocalSettings (non-secret connection metadata only)

LocalSettings
  └──> DataStorage

DataStorage
  └──> no other Foundation module
```

Credentials and secrets are not ordinary settings. ServiceAccess refers to
secure platform credential storage through an explicit abstraction.

## Module lifecycle

1. Record at least two intended consumers.
2. Define the capability boundary and public contract.
3. Add only the structure required by the first implementation.
4. Add tests before or alongside implementation where technically possible.
5. Document general and platform-specific build requirements.
6. Version and release modules so applications can update deliberately.
