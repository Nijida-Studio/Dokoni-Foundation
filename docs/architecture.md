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
  Sources/
    <responsibility-specific groups when needed>
```

- Every compiled Swift file is below the module's `Sources/` directory.
- `API/`, `Models/`, `Operations/`, and `Connectors/` are optional
  internal organization beneath `Sources/`, not parallel module roots.
- Empty placeholder directories are not created before an implementation needs
  them.

Platform, UI, binding, test, and build areas are added later when concrete code
requires them. Build-system target boundaries may refine this logical layout
without changing module ownership.

## Resource, data, and settings boundary

ResourceAccess owns how a resource is located, authorized, opened, retained,
and closed. A local file follows the same access flow as a remote service or
database even though their concrete connection capabilities differ.

DataStorage performs storage operations through an opened, capability-specific
connection. Its first operation streams opaque byte chunks into a
caller-provided receiver. It does not decode or semantically modify the data.

```text
Settings resolves the operating system, location, and receiver
        |
ResourceAccess creates/opens a typed resource connection
        |
DataStorage streams data through that connection into the receiver
        |
Settings decodes, validates, modifies, and encodes settings
```

Resource connections declare whether they are operation-scoped or persistent.
DataStorage closes operation-scoped connections on success and failure.
ResourceAccess retains persistent connections until explicitly closed.

The common access flow does not imply one universal connection type. File
connections expose byte capabilities; future database connections may expose
queries, row streams, commands, and transactions.

## Settings bootstrap

The first executable path uses the ecosystem identifier
`de.nijida.dokonie-es`. Settings determines the current operating system and
resolves the shared `settings.conf` location. ResourceAccess creates the
directory and an initially commented settings file when missing. DataStorage
then streams the file into `SettingsTextReceiver`, after which the command
writes the validated UTF-8 text to standard output.

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
  ├──> Settings
  ├──> DataStorage
  └──> ResourceAccess

Settings
  └──> DataStorage

DataStorage
  └──> ResourceAccess

ResourceAccess
  └──> no other Foundation module
```

Credentials and secrets are not ordinary settings. ResourceAccess refers to
secure platform credential storage through an explicit abstraction.
ResourceAccess never loads Settings itself; callers supply already resolved
access requests, which prevents a bootstrap dependency cycle.

## Module lifecycle

1. Record at least two intended consumers.
2. Define the capability boundary and public contract.
3. Add only the structure required by the first implementation.
4. Add tests before or alongside implementation where technically possible.
5. Document general and platform-specific build requirements.
6. Version and release modules so applications can update deliberately.
