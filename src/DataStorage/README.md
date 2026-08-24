# DataStorage

DataStorage performs storage operations through typed connections supplied by
ResourceAccess without knowing the application's data format.

## Source structure

- `Sources/API/` contains the receiver contract.
- `Sources/Models/` contains DataStorage-owned operation errors.
- `Sources/Operations/` contains the byte-stream reader.

The current `DataStorageReader` forwards configurable chunks to a
`DataStreamReceiver`. It closes operation-scoped connections on success and
failure and leaves persistent connections open for ResourceAccess to manage.

A consuming module decodes, modifies, and encodes content. Future operations
may include byte writing or structured database access; application semantics
remain outside DataStorage.
