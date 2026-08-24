import Foundation

/// Describes how ResourceAccess should open a local file.
public struct LocalFileAccessRequest: Sendable, Equatable {
    public let fileURL: URL
    public let createIfMissing: Bool
    public let initialContents: Data
    public let lifetime: ConnectionLifetime

    public init(
        fileURL: URL,
        createIfMissing: Bool = false,
        initialContents: Data = Data(),
        lifetime: ConnectionLifetime = .operation
    ) {
        self.fileURL = fileURL
        self.createIfMissing = createIfMissing
        self.initialContents = initialContents
        self.lifetime = lifetime
    }
}
