// ODTS TASK: https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4

import Foundation

/// Describes how ResourceAccess should open a local file.
///
/// The request is declarative. Constructing it performs no file-system access.
/// ``LocalFileConnector/open(_:)`` standardizes ``fileURL`` and performs any
/// requested creation before returning an open connection.
public struct LocalFileAccessRequest: Sendable, Equatable {
    /// The file to open for reading.
    public let fileURL: URL
    /// Whether the connector may create the file and its parent directories.
    public let createIfMissing: Bool
    /// Bytes written atomically when the file must be created.
    ///
    /// Existing files are never replaced with this value.
    public let initialContents: Data
    /// The ownership policy for the resulting connection.
    public let lifetime: ConnectionLifetime

    /// Creates a local-file access description.
    ///
    /// - Parameters:
    ///   - fileURL: Location of the file resource. The connector standardizes
    ///     the URL before opening and caching it.
    ///   - createIfMissing: When `true`, create missing parent directories and
    ///     initialize an absent file. Defaults to `false`.
    ///   - initialContents: Initial file bytes used only during creation.
    ///     Defaults to empty data.
    ///   - lifetime: Whether one operation or the connector owns closing the
    ///     connection. Defaults to ``ConnectionLifetime/operation``.
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
