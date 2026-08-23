# DataDistribution

DataDistribution is the Foundation module for distributing settings and user
data beyond one local installation.

## Responsibility

- synchronize data for one user across that user's devices,
- use providers such as iCloud for distribution,
- share explicitly with another person,
- support explicitly defined family sharing,
- model ownership, permissions, revocation, conflicts, and provenance.

Device synchronization, sharing with another person, and family sharing are
distinct authorization and privacy cases. The module must not treat them as
equivalent or enable sharing implicitly.

DataDistribution may use LocalSettings for local state and ServiceAccess for
transports or provider access.

## Planned internal structure

The portable implementation is written in Swift. Concrete code may introduce
separate targets under `Sources/Core`, `Sources/Platforms/<Platform>`,
`Sources/UI/SwiftUI`, `Sources/UI/Avalonia`, and
`Sources/Interop/<Binding>`. General build instructions belong under
`Build/README.md`; platform additions belong in separate files under
`Build/`.

Public APIs remain undefined until data ownership, encryption, conflict,
consent, and consumer requirements are documented.
