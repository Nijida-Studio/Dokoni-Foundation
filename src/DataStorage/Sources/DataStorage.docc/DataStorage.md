# ``DataStorage``

Execute format-independent storage operations through typed resource
capabilities.

@Metadata {
    @PageKind(article)
}

## Overview

DataStorage owns operations, not connections and not application meaning. The
current reader reserves an already opened byte capability, requests bounded
chunks in source order, forwards them to a caller-owned receiver, completes the
receiver at end-of-file, and applies the connection lifetime during cleanup.

Chunk boundaries are transport details. Receivers assemble or incrementally
interpret content and must handle characters or records split across chunks.

Future SQL support should be expressed as structured query operations over a
database capability supplied by ResourceAccess. SQL results are not required
to masquerade as a byte stream.

> Note: Documentation work is tracked by [ODTS TASK #4](https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4).

## Topics

### Reading bytes

- ``DataStorageReader``
- ``DataStreamReceiver``

### Errors

- ``DataStorageError``
