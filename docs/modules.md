# Module Catalog

The repository is organized by library. Concrete package and target names remain
open until the first contracts and consumers are defined.

## LocalSettings

**Status:** Accepted module; public API not yet defined

LocalSettings reads, writes, validates, migrates, and manages settings that
belong to one local installation.

It should define:

- typed settings and defaults,
- schema/version migration,
- atomic updates and recovery,
- observation of local changes,
- separation of ordinary settings from credentials,
- platform storage locations through adapters,
- deterministic in-memory test storage.

LocalSettings does not decide whether settings are synchronized to another
device or shared with another person. That belongs to DataDistribution.

## ServiceAccess

**Status:** Accepted module; public API not yet defined

ServiceAccess models and manages access to services reachable locally, through
a LAN, or through a WAN. Examples include GitHub, WebDAV, CalDAV, and SMB.

It should define:

- service and endpoint identity,
- connection profiles and capability discovery,
- authentication references without treating secrets as ordinary settings,
- connectivity, availability, error, cancellation, and retry semantics,
- provider/protocol adapters,
- safe test doubles and integration-test boundaries.

ServiceAccess provides access to services; it does not own Kizuna
synchronization, Souran DevOps workflows, or another application's product
logic. The existing shared GitHub capability becomes a ServiceAccess adapter
rather than a separate top-level module.

## DataDistribution

**Status:** Accepted module; public API not yet defined

DataDistribution coordinates how settings and user data move beyond one local
installation.

It distinguishes at least:

- synchronization for the same user across that user's devices,
- distribution through a provider such as iCloud,
- explicit sharing with another person,
- explicit family sharing,
- ownership, permissions, revocation, conflict handling, and provenance.

DataDistribution may use LocalSettings for local state and ServiceAccess for
transports and provider access. It must not assume that device synchronization,
person-to-person sharing, and family sharing have identical authorization or
privacy semantics.

## Optional UI integration

Every module may later add optional SwiftUI or Avalonia targets for focused,
reusable embedding components. The platform-neutral core remains UI-independent.
Complete screens, navigation, and application workflows remain in the consuming
applications.

## Admission and implementation status

The three modules are accepted as the initial Foundation structure by explicit
maintainer decision. Before concrete public APIs are finalized, their first
consumers, supported platforms, target boundaries, test contracts, and release
channels must be recorded.
