import Foundation

/// Receives opaque byte chunks produced by a DataStorage read operation.
///
/// The receiver, rather than DataStorage, decides how the bytes are assembled
/// or interpreted.
public protocol DataStreamReceiver: Sendable {
    func receive(_ chunk: Data) async throws
    func finish() async throws
}
