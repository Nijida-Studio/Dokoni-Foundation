import Foundation

/// A serialized connection to one local file.
///
/// The actor protects the file offset and close operation when callers use a
/// persistent connection from concurrent tasks.
public actor LocalFileConnection: ReadableByteConnection {
    public nonisolated let fileURL: URL
    public nonisolated let lifetime: ConnectionLifetime

    private var fileHandle: FileHandle?
    private var isReading = false

    init(fileURL: URL, lifetime: ConnectionLifetime) throws {
        self.fileURL = fileURL
        self.lifetime = lifetime
        fileHandle = try FileHandle(forReadingFrom: fileURL)
    }

    public var isClosed: Bool {
        fileHandle == nil
    }

    public func beginReading() throws {
        guard !isReading else {
            throw ResourceAccessError.connectionBusy(fileURL)
        }
        let handle = try openHandle()
        try handle.seek(toOffset: 0)
        isReading = true
    }

    public func read(maximumByteCount: Int) throws -> Data? {
        guard maximumByteCount > 0 else {
            throw ResourceAccessError.invalidReadSize(maximumByteCount)
        }
        guard isReading else {
            throw ResourceAccessError.connectionBusy(fileURL)
        }

        return try openHandle().read(upToCount: maximumByteCount)
    }

    public func endReading() {
        isReading = false
    }

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
