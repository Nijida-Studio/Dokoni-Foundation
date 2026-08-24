// ODTS TASK: https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4

/// Determines who closes a resource connection after a storage operation.
///
/// The lifetime is an ownership contract, not a performance hint. Storage
/// operations use it to decide whether cleanup includes closing the resource.
/// Connector implementations use it to decide whether an open connection is
/// retained for later reuse.
public enum ConnectionLifetime: Sendable, Equatable {
    /// The consumer of the connection closes it after one operation, whether
    /// that operation succeeds or fails.
    case operation

    /// The connector retains and reuses the connection until it is explicitly
    /// closed.
    case persistent
}
