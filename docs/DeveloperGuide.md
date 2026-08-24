# Dokoni Foundation Developer Guide

This guide is the narrative companion to the generated Swift API reference.
It explains why the Foundation modules exist, how they collaborate, and which
contracts an application or future adapter must preserve.

The implementation tracked by
[ODTS TASK #4](https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4)
establishes this guide and the first DocC catalogs.

## Audience

Read this guide when you:

- integrate a Dokoni ecosystem application with Foundation;
- add a resource connector such as SQL, WebDAV, SMB, or GitHub;
- add a DataStorage operation such as writing, querying, or transactions;
- define the Settings data format;
- begin implementation of DataDistribution;
- review connection ownership, cancellation, error handling, or concurrency;
- maintain the generated developer documentation.

## Package products

The package currently publishes three libraries and one executable:

| Product | Role |
| --- | --- |
| **ResourceAccess** | Locates, creates, opens, retains, and closes access to resources. |
| **DataStorage** | Performs storage operations through capabilities supplied by ResourceAccess. |
| **Settings** | Owns settings locations, bootstrap data, decoding, validation, and future settings semantics. |
| **settings-test-app** | Demonstrates and verifies the first complete local-settings startup flow. |

DataDistribution is an accepted fourth Foundation module but does not yet
publish a Swift target. Its boundary is documented in
[DataDistribution](DataDistribution.md).

## Dependency direction

~~~text
Application composition root
  ├──> Settings
  ├──> DataStorage
  └──> ResourceAccess

Settings
  └──> DataStorage

DataStorage
  └──> ResourceAccess

ResourceAccess
  └──> Foundation and platform SDKs only
~~~

The dependency direction is deliberate:

1. ResourceAccess must be usable before settings are loaded.
2. DataStorage consumes resource capabilities but does not open resources.
3. Settings may process data but must not bypass the storage operation.
4. ResourceAccess must never load Settings internally, because that would
   create a bootstrap dependency cycle.
5. Application-specific workflows remain in the application repository.

## First startup flow

The command-line application implements the first end-to-end flow:

1. **OperatingSystem.current** detects the compiled operating system.
2. **SettingsLocationResolver** selects the user-specific configuration root.
3. **SettingsBootstrapPlanner** creates a **SettingsReadPlan**.
4. **LocalFileConnector** creates the parent directory and initial settings file
   when they do not exist.
5. ResourceAccess returns a **LocalFileConnection**.
6. **DataStorageReader** reserves the connection and reads configurable chunks.
7. Every chunk is sent to **SettingsTextReceiver**.
8. The receiver validates that the complete stream is UTF-8.
9. DataStorage releases the read reservation.
10. An operation-scoped connection is closed automatically; a persistent
    connection remains managed by its connector.
11. The application requests the completed text and writes it to standard
    output.

This sequence is the reference composition. Individual modules do not hide the
ownership transitions, which makes cleanup and errors testable.

## Shared settings location

The shared ecosystem identifier is **de.nijida.dokonie-es**, and the first
shared file is **settings.conf**.

Default roots are selected as follows:

| Platform | Base directory |
| --- | --- |
| macOS and iOS | User Application Support directory |
| Linux and Android | XDG_CONFIG_HOME, otherwise HOME/.config |
| Windows | APPDATA |

The resulting path appends:

~~~text
de.nijida.dokonie-es/settings.conf
~~~

Applications may place their own data below the ecosystem directory. Shared
settings must continue to use the root settings.conf unless a later versioned
settings contract changes that decision.

For tests and diagnostic command runs, **DOKONI_SETTINGS_ROOT** overrides only
the base directory. Production applications should normally use the platform
resolver rather than inventing paths.

## ResourceAccess contracts

ResourceAccess answers the question:

> How is a resource located, prepared, opened, retained, and closed?

It does not answer:

> What does the stored information mean?

### Capabilities instead of a universal connection

A local file exposes readable bytes. A database may expose row queries,
commands, and transactions. GitHub may expose repository content as bytes but
Issues and pull requests as provider-specific operations.

Do not add a large source-type switch to DataStorage. Add a narrow capability
protocol and an adapter that implements it.

### Connection lifetimes

**ConnectionLifetime.operation** means:

- a connector returns a fresh connection;
- DataStorage closes it after one operation;
- DataStorage also attempts to close it when reading or receiving fails;
- callers must not expect reuse.

**ConnectionLifetime.persistent** means:

- the connector may cache and return the same connection;
- DataStorage releases the current operation but does not close the connection;
- the owner calls the connector's explicit close API;
- a failed close must not silently remove the connection from connector
  management.

### Concurrency

**LocalFileConnection** is an actor because FileHandle maintains a mutable
offset. **beginReading()** reserves the complete operation. A second operation
must fail with **connectionBusy** rather than interleave chunks from two
readers. **endReading()** releases the reservation without closing a persistent
connection.

An adapter for a naturally multiplexed resource may implement a different
internal strategy, but it must preserve the public capability semantics.

## DataStorage contracts

DataStorage answers the question:

> Which storage operation is performed through an already opened capability?

The first operation is chunked byte reading.

### Receiver ownership

The caller creates the receiver because the caller owns data interpretation.
DataStorage invokes **receive(_:)** for every non-empty chunk in source order,
then invokes **finish()** exactly once after the source reaches its end.

A receiver must be Sendable. Mutable receivers should normally be actors so
they can safely accumulate data across asynchronous calls.

### Buffering

**DataStorageReader** defaults to 64 KiB chunks. The size is configurable so
tests can force multiple chunks and applications can tune memory and
throughput. A size of zero or less is rejected before resource access begins.

DataStorage does not promise that one chunk corresponds to a line, character,
record, or application object. UTF-8 code units and structured values may cross
chunk boundaries; the receiver must assemble or incrementally decode them.

### Cleanup and error precedence

When an operation fails, the original operation or receiver error remains the
reported error. Cleanup is attempted for an operation-scoped connection, but a
secondary close error does not replace the original failure.

Persistent connections are left open after a storage failure. Their owner may
retry, inspect, or close them through ResourceAccess.

## Settings contracts

Settings answers the question:

> Where are settings expected, and how are their bytes interpreted as settings?

The current implementation stops after UTF-8 validation. It intentionally does
not yet define keys, value types, merging, migration, local-versus-remote
precedence, or secret handling.

### Bootstrap data

The initial file contains comments only. It is created atomically and only when
the file is absent. Existing files are never replaced by bootstrap content.

Future bootstrap settings may identify whether the effective settings are local
or remote and may contain a non-secret resource profile. Credentials must be
stored in a secure platform facility and referenced indirectly.

### Operating-system detection

**OperatingSystem.current** uses compile-time platform conditions. It does not
probe the host dynamically. This makes the result deterministic for the built
binary and testable through explicit resolver inputs.

### Location resolution

**SettingsLocationResolver** computes a URL but performs no file access.
ResourceAccess remains the only module that creates directories or opens the
resource.

## DataDistribution boundary

DataDistribution coordinates movement beyond one local installation:

- synchronization between devices belonging to the same user;
- distribution through a provider;
- explicit sharing with another person;
- explicit family sharing;
- conflicts, provenance, ownership, permissions, and revocation.

Those cases are not interchangeable. No sharing mode may be enabled implicitly.
DataDistribution may use Settings, DataStorage, and ResourceAccess but must not
move their responsibilities into its own API.

## Adding a resource connector

Before writing an adapter:

1. Create an ODTS Epic, Item, and Task or attach to an existing hierarchy.
2. Identify at least two concrete Foundation consumers.
3. Describe the resource's capabilities rather than its vendor name alone.
4. Decide who owns credentials and how they are referenced.
5. Define lifetime, cancellation, retry, and concurrency behavior.
6. Create the protocol and type skeleton with rudimentary DocC comments.
7. Add contract tests and test doubles.
8. Implement the adapter.
9. Update the relevant DocC topics and traceability map.

Place concrete connectors below:

~~~text
src/ResourceAccess/Sources/Connectors/<Connector>/
~~~

Do not expose provider SDK types from a cross-provider capability unless the
contract explicitly requires them.

## Adding a DataStorage operation

Examples include writing bytes, atomic replacement, SQL queries, row streams,
commands, or transactions.

1. Define the exact capability required from ResourceAccess.
2. Keep application semantics out of the operation.
3. Specify ordering, buffering, cancellation, and cleanup.
4. Define operation-owned errors in DataStorage.
5. Add tests for success, partial progress, receiver failure, connection
   failure, and lifetime behavior.
6. Document whether retry is safe and which layer owns it.

Place operations below:

~~~text
src/DataStorage/Sources/Operations/
~~~

## Error ownership

Errors belong to the layer that can explain and act on them:

- ResourceAccess: locating, opening, connection state, permissions, access
  capability misuse.
- DataStorage: operation configuration and storage-operation behavior.
- Settings: location policy, format, decoding, validation, and migration.
- DataDistribution: conflicts, consent, ownership, sharing, and provenance.

Do not translate every error into a generic Foundation error. Preserve the
underlying context or wrap it with a documented causal relationship.

## Testing strategy

Tests remain in package-level test targets:

~~~text
Tests/
  ResourceAccessTests/
  DataStorageTests/
  SettingsTests/
~~~

This keeps tests outside production targets while preserving clear module
ownership in SwiftPM and Xcode.

Required test categories for the current implementation include:

- first-run directory and file creation;
- preservation of an existing file;
- missing-resource failure;
- operation-scoped connection independence;
- persistent connection reuse and explicit closing;
- busy-connection protection;
- multi-chunk ordering;
- receiver failure cleanup;
- invalid operation configuration;
- platform path resolution;
- invalid UTF-8 rejection.

## Documentation maintenance

Swift public APIs use DocC-compatible triple-slash comments. A public
declaration should document, when applicable:

- purpose and ownership boundary;
- preconditions and invariants;
- parameters and returned values;
- thrown errors and cleanup behavior;
- actor isolation and concurrency;
- connection or object lifetime;
- an example for non-obvious usage;
- the implementing ODTS Task.

Each implemented target owns a .docc catalog below its Sources directory.
Narrative cross-module guidance lives under docs.

Documentation is part of completion, not a later publishing step. Run the
documentation validation described in [Contributing](../CONTRIBUTING.md)
before completing an ODTS Task.

## ODTS traceability

The repository convention is defined in
[ODTS Traceability](ODTSTraceability.md). Runtime behavior must not depend on
GitHub availability. Traceability is carried by comments and documentation,
never by network calls in Foundation code.
