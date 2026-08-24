// ODTS TASK: https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4

import Foundation

/// An opened resource that can supply bytes.
///
/// ResourceAccess owns how the resource is located, prepared and opened.
/// DataStorage owns the read operation performed through this capability. The
/// protocol deliberately models only ordered byte reading; databases and other
/// structured resources should expose separate query or transaction
/// capabilities instead of pretending that every operation is a byte stream.
///
/// A complete operation has the following lifecycle:
///
/// 1. Call ``beginReading()`` once.
/// 2. Call ``read(maximumByteCount:)`` until it returns `nil`.
/// 3. Call ``endReading()`` exactly once for the successful reservation.
/// 4. Call ``close()`` if ownership and ``lifetime`` require it.
///
/// Implementations must serialize or reject incompatible concurrent operations
/// and must document whether repeated reads restart at the beginning.
public protocol ReadableByteConnection: Sendable {
    /// The lifetime selected when the connection was opened.
    ///
    /// DataStorage uses this value to decide whether the connection is closed
    /// after the operation or retained for explicit connector management.
    var lifetime: ConnectionLifetime { get async }

    /// Whether the underlying resource has already been closed.
    ///
    /// A closed connection cannot begin another read. Closing an already closed
    /// connection should be idempotent unless an implementation documents a
    /// narrower contract.
    var isClosed: Bool { get async }

    /// Reserves and positions the connection for one complete read operation.
    ///
    /// - Throws: A resource-specific error if the connection is closed, busy,
    ///   cannot be positioned, or otherwise cannot start reading.
    func beginReading() async throws

    /// Returns the next chunk, or `nil` when the end is reached.
    ///
    /// - Parameter maximumByteCount: Upper bound for returned bytes. Callers
    ///   must supply a positive value.
    /// - Returns: The next block of bytes, or `nil` at end-of-resource.
    /// - Throws: A resource-specific error when the size is invalid or the
    ///   active reservation cannot continue.
    func read(maximumByteCount: Int) async throws -> Data?

    /// Releases the read reservation without closing the connection.
    ///
    /// Calling this after a failed or completed operation allows a persistent
    /// connection to participate in a later operation.
    func endReading() async

    /// Releases the underlying resource.
    ///
    /// - Throws: A resource-specific cleanup error. Implementations should make
    ///   repeated calls harmless after a successful close.
    func close() async throws
}
