# Settings

Settings owns settings locations, formats, validation, and processing
independently of where settings are persisted. It replaces LocalSettings
because settings may later be loaded from local or remote resources.

## First implementation

The module:

- identifies the current operating system,
- resolves the shared `de.nijida.dokonie-es/settings.conf` location,
- provides the initial commented UTF-8 file contents,
- supplies a receiver that assembles and validates streamed UTF-8 text,
- creates the bootstrap read plan used by the command-line test app.

ResourceAccess opens the resource, and DataStorage streams its contents.
Settings owns the meaning and later parsing of those contents.

## Source structure

- `Sources/API/` contains location resolution and stream reception.
- `Sources/Models/` contains operating-system, defaults, and bootstrap-plan
  models.

Settings has no `Store/` group because it does not open or persist resources
itself.

See the [developer handbook](../../docs/DeveloperGuide.md) for bootstrap and
platform-location behavior. The generated symbol reference starts at
`Sources/Settings.docc`.
