// ODTS TASK: https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4

import Foundation
import ResourceAccess

/// Streams bytes from an opened resource into a caller-provided receiver.
///
/// `DataStorageReader` knows the read operation, but neither the concrete
/// resource type nor the meaning of its content. The source is supplied as a
/// readable-byte capability supplied by ResourceAccess, and interpretation is
/// delegated to a ``DataStreamReceiver``.
///
/// The value is immutable and `Sendable`; one instance can therefore configure
/// several independent operations. Concurrency on a single connection remains
/// governed by that connection's capability contract.
///
///     let reader = try DataStorageReader(chunkSize: 4_096)
///     try await reader.read(from: connection, into: receiver)
///
/// - SeeAlso: ``DataStreamReceiver``
public struct DataStorageReader: Sendable {
    /// The maximum number of bytes requested for each source read.
    ///
    /// The source may return fewer bytes. Chunk boundaries never imply record,
    /// line, character, or message boundaries.
    public let chunkSize: Int

    /// Creates a chunked byte reader.
    ///
    /// - Parameter chunkSize: Maximum number of bytes requested per read. The
    ///   default is 64 KiB. It must be greater than zero.
    /// - Throws: ``DataStorageError/invalidChunkSize(_:)`` when `chunkSize` is
    ///   zero or negative. Validation happens before any connection is used.
    public init(chunkSize: Int = 64 * 1024) throws {
        guard chunkSize > 0 else {
            throw DataStorageError.invalidChunkSize(chunkSize)
        }
        self.chunkSize = chunkSize
    }

    /// Reads the complete resource and completes the receiver.
    ///
    /// The method reserves the ResourceAccess connection for reading, forwards
    /// every non-empty chunk to ``DataStreamReceiver/receive(_:)``, and calls
    /// ``DataStreamReceiver/finish()`` after end-of-file. It always releases a
    /// successful reservation with `endReading()`.
    ///
    /// Operation-scoped connections are closed on success and failure.
    /// Persistent connections remain open for reuse by their connector. If the
    /// operation fails and closing also fails, the original operation error is
    /// preserved.
    ///
    /// - Parameters:
    ///   - connection: An already opened readable capability. DataStorage does
    ///     not locate, create, authenticate, or open the underlying resource.
    ///   - receiver: A caller-owned processor for the ordered byte chunks.
    /// - Throws: Errors from reserving or reading the connection, from the
    ///   receiver, or from closing an operation-scoped connection after a
    ///   successful read.
    /// - Important: Do not assume the receiver is completed if this method
    ///   throws. A receiver should document whether it can be discarded, reset,
    ///   or reused after failure.
    public func read<Connection, Receiver>(
        from connection: Connection,
        into receiver: Receiver
    ) async throws
    where Connection: ReadableByteConnection, Receiver: DataStreamReceiver {
        let shouldClose = await connection.lifetime == .operation
        var didBeginReading = false

        do {
            try await connection.beginReading()
            didBeginReading = true

            while let chunk = try await connection.read(
                maximumByteCount: chunkSize
            ) {
                guard !chunk.isEmpty else {
                    break
                }
                try await receiver.receive(chunk)
            }

            try await receiver.finish()
            await connection.endReading()
            didBeginReading = false

            if shouldClose {
                try await connection.close()
            }
        } catch {
            if didBeginReading {
                await connection.endReading()
            }
            if shouldClose {
                try? await connection.close()
            }
            throw error
        }
    }
}
