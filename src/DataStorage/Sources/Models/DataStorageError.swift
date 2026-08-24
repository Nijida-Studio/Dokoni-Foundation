// ODTS TASK: https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4

/// Errors raised while configuring or executing a storage operation.
public enum DataStorageError: Error, Sendable, Equatable {
    /// The requested byte-buffer size cannot make forward progress.
    ///
    /// - Parameter: The invalid number supplied to
    ///   ``DataStorageReader/init(chunkSize:)``.
    case invalidChunkSize(Int)
}
