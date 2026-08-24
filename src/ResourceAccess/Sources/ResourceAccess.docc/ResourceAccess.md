# ``ResourceAccess``

Locate, prepare, open, retain, and close typed resource capabilities.

@Metadata {
    @PageKind(article)
}

## Overview

ResourceAccess is the connection-management boundary of Dokoni Foundation. It
knows how to reach a resource but does not interpret the information stored in
it. Applications and higher modules describe access, ResourceAccess returns a
narrow capability, and DataStorage performs an operation through that
capability.

The first adapter manages local files. It can create an absent file without
overwriting an existing one, provides operation-scoped and persistent
lifetimes, and prevents overlapping reads on the same file handle.

Database adapters should expose query, command, and transaction capabilities;
they should not force structured rows through ``ReadableByteConnection``.

> Note: Documentation work is tracked by [ODTS TASK #4](https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4).

## Topics

### Byte-reading capability

- ``ReadableByteConnection``
- ``ConnectionLifetime``

### Local-file access

- ``LocalFileAccessRequest``
- ``LocalFileConnector``
- ``LocalFileConnection``

### Errors

- ``ResourceAccessError``
