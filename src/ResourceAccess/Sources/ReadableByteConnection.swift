import Foundation

/// An opened resource that can supply bytes.
///
/// ResourceAccess owns how the resource is located, prepared and opened.
/// DataStorage owns the read operation performed through this capability.
public protocol ReadableByteConnection: Sendable {
    /// The lifetime selected when the connection was opened.
    var lifetime: ConnectionLifetime { get async }

    /// Whether the underlying resource has already been closed.
    var isClosed: Bool { get async }

    /// Reserves and positions the connection for one complete read operation.
    func beginReading() async throws

    /// Returns the next chunk, or `nil` when the end is reached.
    func read(maximumByteCount: Int) async throws -> Data?

    /// Releases the read reservation without closing the connection.
    func endReading() async

    /// Releases the underlying resource.
    func close() async throws
}
