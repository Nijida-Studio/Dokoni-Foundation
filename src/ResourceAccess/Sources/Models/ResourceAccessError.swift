// ODTS TASK: https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4

import Foundation

/// Errors raised while locating, opening or using a resource.
public enum ResourceAccessError: Error, Sendable, Equatable {
    /// A read request specified a non-positive maximum number of bytes.
    case invalidReadSize(Int)
    /// The requested resource was absent and creation was not authorized.
    case resourceDoesNotExist(URL)
    /// An operation attempted to use a connection after it was closed.
    case connectionClosed(URL)
    /// A second or incompatible operation attempted to use a reserved resource.
    case connectionBusy(URL)
}

extension ResourceAccessError: LocalizedError {
    /// A user-readable summary suitable for command-line diagnostics and logs.
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
