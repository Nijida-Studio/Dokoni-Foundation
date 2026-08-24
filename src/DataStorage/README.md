# DataStorage

DataStorage performs storage operations through typed connections supplied by
ResourceAccess without knowing the application's data format.

## Initial structure

- `Models/` contains storage identifiers, locations, and storage errors.
- `Sources/` contains the first Swift byte-stream API.
- `Store/` records future storage operation implementations.
- `API/` records the interface exposed to other modules.

The current `DataStorageReader` forwards configurable chunks to a
`DataStreamReceiver`. It closes operation-scoped connections on success and
failure and leaves persistent connections open for ResourceAccess to manage.

A consuming module decodes, modifies, and encodes content. Future operations
may include byte writing or structured database access; application semantics
remain outside DataStorage.
