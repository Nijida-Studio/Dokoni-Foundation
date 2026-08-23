# Module Catalog

The repository is organized by library. Concrete package and target names remain
open until the first contracts and consumers are defined.

## DataStorage

**Status:** Accepted module; public API not yet defined

DataStorage reads and writes opaque data without owning the data format.

It should define:

- identifiers or locations for stored data,
- reading data,
- writing or replacing data,
- absence and storage errors,
- atomic replacement where supported,
- storage implementations supplied later for concrete platforms or locations.

DataStorage does not decode or semantically modify the data. The consuming
module owns its format and transforms the content before writing it back.

## LocalSettings

**Status:** Initial structure established; public API not yet defined

LocalSettings owns settings models, their format, the settings store, and the
interface used by other modules.

Its first structure is:

- `Models/` for settings data,
- `Store/` for reading, modifying, and managing settings through DataStorage,
- `API/` for queries and changes requested by other modules.

Credentials and secrets are not ordinary settings. Synchronization and sharing
belong to DataDistribution.

## ServiceAccess

**Status:** Accepted module; public API not yet defined

ServiceAccess models and manages access to services reachable locally, through
a LAN, or through a WAN. Examples include GitHub, WebDAV, CalDAV, and SMB.

ServiceAccess provides access to services; it does not own Kizuna
synchronization, Souran DevOps workflows, or another application's product
logic.

## DataDistribution

**Status:** Accepted module; public API not yet defined

DataDistribution coordinates how settings and user data move beyond one local
installation. It distinguishes same-user device synchronization, provider
distribution, sharing with another person, and family sharing.

DataDistribution may use LocalSettings for local state and ServiceAccess for
transports and provider access.

## Optional UI integration

Every module may later add optional SwiftUI or Avalonia targets for focused,
reusable embedding components. The platform-neutral core remains UI-independent.
Complete screens, navigation, and application workflows remain in consuming
applications.

## Admission and implementation status

The four modules are accepted as the initial Foundation structure. Before
concrete public APIs are finalized, their first consumers, supported platforms,
target boundaries, test contracts, and release channels must be recorded.
