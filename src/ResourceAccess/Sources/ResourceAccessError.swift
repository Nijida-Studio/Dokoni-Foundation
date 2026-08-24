import Foundation

/// Errors raised while locating, opening or using a resource.
public enum ResourceAccessError: Error, Sendable, Equatable {
    case invalidReadSize(Int)
    case resourceDoesNotExist(URL)
    case connectionClosed(URL)
    case connectionBusy(URL)
}

extension ResourceAccessError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .invalidReadSize(size):
            "The requested read size must be greater than zero; received \(size)."
        case let .resourceDoesNotExist(url):
            "The resource does not exist: \(url.path)"
        case let .connectionClosed(url):
            "The resource connection is already closed: \(url.path)"
        case let .connectionBusy(url):
            "The resource connection is already performing an operation: \(url.path)"
        }
    }
}
