# Module Catalog

The repository is organized by library. Concrete package and target names remain
open until the first contracts and consumers are defined.

## DataStorage

**Status:** First byte-stream read API implemented

DataStorage performs storage operations using typed connections supplied by
ResourceAccess. It does not own the application meaning of the data.

The first API defines:

- configurable chunked reading,
- caller-provided stream receivers,
- completion and error propagation,
- automatic closing of operation-scoped connections,
- reuse of explicitly persistent connections.

DataStorage does not decode or semantically modify the data. The consuming
module owns its format and transforms the content before writing it back.
Future adapters may add writing, SQL row streams, commands, and transactions
without placing source connection management in DataStorage.

## Settings

**Status:** First local settings bootstrap implemented

Settings owns settings models, locations, formats, validation, and processing
regardless of whether persistence is local or remote.

The first implementation provides:

- current operating-system detection,
- shared path resolution for `de.nijida.dokonie-es/settings.conf`,
- the initial commented file contents,
- a UTF-8 stream receiver,
- a bootstrap read plan consumed by the command-line test app.

Credentials and secrets are not ordinary settings. Synchronization and sharing
belong to DataDistribution.

## ResourceAccess

**Status:** First local-file connector implemented

ResourceAccess manages access to local and remote data sources. It owns resource
location, authorization, connection creation, lifetime, reuse, and closing.
Examples include local files, GitHub, WebDAV, CalDAV, SMB, and databases.

Its first adapter creates missing local directories and files, opens a
serialized file connection, and supports operation-scoped or persistent
lifetimes. ResourceAccess does not own storage decoding, Kizuna
synchronization, Souran workflows, or application product logic.

## DataDistribution

**Status:** Accepted module; public API not yet defined

DataDistribution coordinates how settings and user data move beyond one local
installation. It distinguishes same-user device synchronization, provider
distribution, sharing with another person, and family sharing.

DataDistribution may use Settings for configuration, ResourceAccess for
managed sources, and DataStorage for storage operations.

## Optional UI integration

Every module may later add optional SwiftUI or Avalonia targets for focused,
reusable embedding components. The platform-neutral core remains UI-independent.
Complete screens, navigation, and application workflows remain in consuming
applications.

## Admission and implementation status

The four modules are accepted as the initial Foundation structure. The first
Swift package slice implements local settings reading on macOS and models
Linux, Windows, Android, and iOS path selection for later platform builds.
