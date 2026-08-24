# ResourceAccess

ResourceAccess locates, opens, retains, and closes access to local or remote
resources. It replaces the narrower ServiceAccess name so every application can
use the same logical access flow for files, databases, LAN resources, and WAN
services.

## First implementation

The local-file adapter:

- creates a missing parent directory and file when requested,
- preserves an existing file,
- returns a typed readable-byte connection,
- supports operation-scoped and persistent lifetimes,
- serializes and guards complete read operations,
- closes persistent connections only through explicit connector operations.

ResourceAccess does not interpret or transform stored data. DataStorage performs
operations through the opened capability. Credentials remain behind secure
platform abstractions when future resource types require authentication.

## Source structure

- `Sources/API/` contains resource capability contracts.
- `Sources/Models/` contains requests, lifetimes, and access errors.
- `Sources/Connectors/LocalFile/` contains the first concrete connector.
