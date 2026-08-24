import Foundation
import ResourceAccess

/// Streams bytes from an opened resource into a caller-provided receiver.
public struct DataStorageReader: Sendable {
    public let chunkSize: Int

    public init(chunkSize: Int = 64 * 1024) throws {
        guard chunkSize > 0 else {
            throw DataStorageError.invalidChunkSize(chunkSize)
        }
        self.chunkSize = chunkSize
    }

    /// Reads all chunks and completes the receiver.
    ///
    /// Operation-scoped connections are closed on success and failure.
    /// Persistent connections remain open for reuse by their connector.
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
