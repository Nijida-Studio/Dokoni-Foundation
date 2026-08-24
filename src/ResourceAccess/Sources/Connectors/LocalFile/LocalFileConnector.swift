import Foundation

/// Opens and manages access to local files.
///
/// Operation-scoped connections are returned to the caller and closed by
/// DataStorage. Persistent connections are cached and reused until one of the
/// explicit close methods is called.
public actor LocalFileConnector {
    private let fileManager: FileManager
    private var persistentConnections: [URL: LocalFileConnection] = [:]

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

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

    public func closePersistentConnection(for fileURL: URL) async throws {
        let key = fileURL.standardizedFileURL
        guard let connection = persistentConnections[key] else {
            return
        }

        try await connection.close()
        persistentConnections.removeValue(forKey: key)
    }

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
