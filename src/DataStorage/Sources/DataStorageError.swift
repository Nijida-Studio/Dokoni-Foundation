/// Errors raised while configuring or executing a storage operation.
public enum DataStorageError: Error, Sendable, Equatable {
    case invalidChunkSize(Int)
}
