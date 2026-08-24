// ODTS TASK: https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4

import Foundation

/// Opens and manages access to local files.
///
/// Operation-scoped connections are returned to the caller and closed by
/// DataStorage. Persistent connections are cached and reused until one of the
/// explicit close methods is called.
public actor LocalFileConnector {
    private let fileManager: FileManager
    private var persistentConnections: [URL: LocalFileConnection] = [:]

    /// Creates a connector backed by a file manager.
    ///
    /// - Parameter fileManager: Service used to inspect and create resources.
    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    /// Prepares and opens the requested local file.
    ///
    /// Missing files are created only when the request explicitly permits it.
    /// Creation includes intermediate directories and atomically writes the
    /// initial contents. Existing files are never overwritten.
    /// Persistent requests for the same standardized URL reuse an open cached
    /// connection; operation-scoped requests always create a new one.
    ///
    /// - Parameter request: Location, creation, content, and lifetime settings.
    /// - Returns: An open readable local-file connection.
    /// - Throws: A missing-resource error or an underlying file-system error.
    public func open(
        _ request: LocalFileAccessRequest
    ) async throws -> LocalFileConnection {
        let fileURL = request.fileURL.standardizedFileURL

        if request.lifetime == .persistent,
           let existing = persistentConnections[fileURL],
           await !existing.isClosed {
            return existing
        }

        try prepareFile(for: request, at: fileURL)
        let connection = try LocalFileConnection(
            fileURL: fileURL,
            lifetime: request.lifetime
        )

        if request.lifetime == .persistent {
            persistentConnections[fileURL] = connection
        }

        return connection
    }

    /// Closes and forgets the retained connection for one file.
    ///
    /// If none is retained, the method succeeds without work. On close failure,
    /// the connection remains managed so the owner can retry.
    ///
    /// - Parameter fileURL: File whose standardized URL identifies the entry.
    /// - Throws: An error from the connection close operation.
    public func closePersistentConnection(for fileURL: URL) async throws {
        let key = fileURL.standardizedFileURL
        guard let connection = persistentConnections[key] else {
            return
        }

        try await connection.close()
        persistentConnections.removeValue(forKey: key)
    }

    /// Closes every connection retained by this connector.
    ///
    /// - Throws: The first close failure. Previously closed entries remain
    ///   removed; the failing and later entries remain available for retry.
    public func closeAllPersistentConnections() async throws {
        for fileURL in Array(persistentConnections.keys) {
            try await closePersistentConnection(for: fileURL)
        }
    }

    private func prepareFile(
        for request: LocalFileAccessRequest,
        at fileURL: URL
    ) throws {
        guard !fileManager.fileExists(atPath: fileURL.path) else {
            return
        }

        guard request.createIfMissing else {
            throw ResourceAccessError.resourceDoesNotExist(fileURL)
        }

        try fileManager.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try request.initialContents.write(to: fileURL, options: .atomic)
    }
}
