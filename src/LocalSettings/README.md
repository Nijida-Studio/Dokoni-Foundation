# LocalSettings

LocalSettings is the Foundation module for settings that belong to one local
installation.

## Responsibility

- read and write local settings,
- provide defaults and validation,
- migrate stored schemas,
- support atomic updates and recovery,
- expose local change observation,
- isolate platform-specific storage locations,
- provide deterministic test storage.

Credentials and other secrets are not ordinary settings. Synchronization or
sharing of settings belongs to DataDistribution.

## Planned internal structure

The portable implementation is written in Swift. Concrete code may introduce
separate targets under `Sources/Core`, `Sources/Platforms/<Platform>`,
`Sources/UI/SwiftUI`, `Sources/UI/Avalonia`, and
`Sources/Interop/<Binding>`. General build instructions belong under
`Build/README.md`; platform additions belong in separate files under
`Build/`.

Only directories backed by concrete code or instructions should be added.
Public APIs remain undefined until consumers and contract tests are recorded.
