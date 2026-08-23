# ServiceAccess

ServiceAccess is the Foundation module for access to services reachable
locally, through a LAN, or through a WAN.

## Responsibility

- service and endpoint identities,
- connection profiles and capability discovery,
- authentication references,
- connection, availability, retry, error, and cancellation semantics,
- provider and protocol adapters,
- safe test doubles and integration-test boundaries.

Potential adapters include GitHub, WebDAV, CalDAV, and SMB. Credentials remain
in secure platform storage behind an explicit abstraction. Application
workflows such as Kizuna synchronization or Souran DevOps operations do not
belong in this module.

## Planned internal structure

The portable implementation is written in Swift. Concrete code may introduce
separate targets under `Sources/Core`, `Sources/Platforms/<Platform>`,
`Sources/UI/SwiftUI`, `Sources/UI/Avalonia`, and
`Sources/Interop/<Binding>`. General build instructions belong under
`Build/README.md`; platform additions belong in separate files under
`Build/`.

The existing planned shared GitHub capability is represented as a
ServiceAccess adapter. Public APIs remain undefined until consumer contracts
and credential ownership are recorded.
