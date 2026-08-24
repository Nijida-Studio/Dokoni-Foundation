// ODTS TASK: https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4

import Foundation

/// Receives opaque byte chunks produced by a DataStorage read operation.
///
/// The receiver, rather than DataStorage, decides how the bytes are assembled
/// or interpreted. Chunks arrive in source order, but their boundaries have no
/// semantic meaning: a character, line, or serialized value may span several
/// calls to ``receive(_:)``.
///
/// Conforming reference types must be safe to pass across concurrency domains.
/// An actor is generally the simplest implementation when received data is
/// accumulated in mutable state.
///
/// A read operation calls ``finish()`` exactly once after the source reports
/// end-of-file. It does not call `finish()` after `receive(_:)` throws.
///
/// - Important: Implementations interpret content, but must not open or close
///   the resource connection. Connection ownership remains with ResourceAccess
///   and the DataStorage operation.
public protocol DataStreamReceiver: Sendable {
    /// Accepts the next non-empty block of bytes from the resource.
    ///
    /// - Parameter chunk: Opaque bytes in source order. The value is non-empty,
    ///   but its size may be smaller than the reader's configured chunk size.
    /// - Throws: Any receiver-specific validation or processing error. The read
    ///   operation stops immediately and performs its configured cleanup.
    func receive(_ chunk: Data) async throws

    /// Completes processing after every byte has been delivered.
    ///
    /// Use this method for validation that requires the complete payload, such
    /// as final UTF-8 decoding or checking a document terminator.
    ///
    /// - Throws: Any receiver-specific completion or validation error.
    func finish() async throws
}
