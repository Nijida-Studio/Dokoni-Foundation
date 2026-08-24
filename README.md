# Dokoni Foundation

Dokoni Foundation contains reusable libraries for applications in the Dokoni
ecosystem.

The repository is organized by library rather than by implementation language.
Each library owns a platform-neutral Swift core and may add platform adapters,
interop bindings, and optional reusable SwiftUI or Avalonia integration modules.
Application-specific screens, navigation, and workflows remain in their owning
application repositories.

## Initial modules

- **ResourceAccess** locates, opens, retains, and closes access to local or
  remote resources. Local files, GitHub, WebDAV, CalDAV, SMB, and databases are
  example resource adapters.
- **DataStorage** performs storage operations through opened resource
  connections without owning the data's application meaning.
- **Settings** owns settings locations, formats, validation, and processing
  independently of whether settings are stored locally or remotely.
- **DataDistribution** coordinates distribution of settings and user data,
  including synchronization across one user's devices and explicit sharing
  with other people or a family.

## Repository structure

```text
docs/
  architecture.md
  modules.md
src/
  ResourceAccess/
    README.md
    Sources/
      API/
      Models/
      Connectors/
  DataStorage/
    README.md
    Sources/
      API/
      Models/
      Operations/
  Settings/
    README.md
    Sources/
      API/
      Models/
  DataDistribution/
    README.md
```

All compiled Swift files live below their module's `Sources/` directory.
Subdirectories such as `API/`, `Models/`, `Operations/`, or
`Connectors/` are created only when code with that responsibility exists.
Modules without an implementation do not carry empty source placeholders.

Swift is the default implementation language for shared behavior on all
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

## First executable slice

The Swift package contains the `settings-test-app` command. On startup it
detects the operating system through Settings, resolves
`de.nijida.dokonie-es/settings.conf`, asks ResourceAccess to create and open
the local file, streams it through DataStorage into a Settings receiver, and
writes the resulting text to standard output.

On macOS the default location is below the user's Application Support
directory. Set `DOKONI_SETTINGS_ROOT` to use a temporary base directory:

```sh
DOKONI_SETTINGS_ROOT=/tmp/dokoni-settings swift run settings-test-app
```

Pass `--persistent` to select a persistent connection for the run. The
short-lived command closes it explicitly before exiting; long-running
applications retain it until their resource owner closes it.
