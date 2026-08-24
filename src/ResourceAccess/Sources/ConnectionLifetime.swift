/// Determines who closes a resource connection after a storage operation.
public enum ConnectionLifetime: Sendable, Equatable {
    /// The consumer of the connection closes it after one operation, whether
    /// that operation succeeds or fails.
    case operation

    /// The connector retains and reuses the connection until it is explicitly
    /// closed.
    case persistent
}
