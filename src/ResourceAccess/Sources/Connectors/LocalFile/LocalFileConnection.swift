// ODTS TASK: https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4

import Foundation

/// A serialized connection to one local file.
///
/// The actor protects the file offset and close operation when callers use a
/// persistent connection from concurrent tasks. Every successful
/// ``beginReading()`` resets the offset to the start of the file. A concurrent
/// read reservation is rejected rather than interleaved.
///
/// Instances are created by ``LocalFileConnector``. Callers normally work with
/// the ``ReadableByteConnection`` capability instead of constructing a file
/// handle themselves.
public actor LocalFileConnection: ReadableByteConnection {
    /// The standardized URL of the underlying file.
    public nonisolated let fileURL: URL
    /// The close-ownership policy selected by the access request.
    public nonisolated let lifetime: ConnectionLifetime

    private var fileHandle: FileHandle?
    private var isReading = false

    init(fileURL: URL, lifetime: ConnectionLifetime) throws {
        self.fileURL = fileURL
        self.lifetime = lifetime
        fileHandle = try FileHandle(forReadingFrom: fileURL)
    }

    /// Whether the underlying file handle has been released.
    public var isClosed: Bool {
        fileHandle == nil
    }

    /// Reserves the connection and resets its file offset to zero.
    ///
    /// - Throws: ``ResourceAccessError/connectionBusy(_:)`` if another read is
    ///   reserved, ``ResourceAccessError/connectionClosed(_:)`` if the file is
    ///   closed, or an error from repositioning the file handle.
    public func beginReading() throws {
        guard !isReading else {
            throw ResourceAccessError.connectionBusy(fileURL)
        }
        let handle = try openHandle()
        try handle.seek(toOffset: 0)
        isReading = true
    }

    /// Reads the next bytes from the active file reservation.
    ///
    /// - Parameter maximumByteCount: Positive upper bound for returned bytes.
    /// - Returns: The next data block, or `nil` after end-of-file.
    /// - Throws: An invalid-size, busy, closed-connection, or file-read error.
    public func read(maximumByteCount: Int) throws -> Data? {
        guard maximumByteCount > 0 else {
            throw ResourceAccessError.invalidReadSize(maximumByteCount)
        }
        guard isReading else {
            throw ResourceAccessError.connectionBusy(fileURL)
        }

        return try openHandle().read(upToCount: maximumByteCount)
    }

    /// Releases the current read reservation without closing the file.
    ///
    /// The method is idempotent and permits a persistent connection to begin a
    /// later read from offset zero.
    public func endReading() {
        isReading = false
    }

    /// Closes the underlying file handle.
    ///
    /// Closing an already closed connection succeeds without work. Closing is
    /// rejected while a read reservation is active.
    ///
    /// - Throws: ``ResourceAccessError/connectionBusy(_:)`` during an active
    ///   read, or an error from closing the file handle.
    public func close() throws {
        guard !isReading else {
            throw ResourceAccessError.connectionBusy(fileURL)
        }
        guard let handle = fileHandle else {
            return
        }

        try handle.close()
        fileHandle = nil
    }

    private func openHandle() throws -> FileHandle {
        guard let fileHandle else {
            throw ResourceAccessError.connectionClosed(fileURL)
        }

        return fileHandle
    }
}
