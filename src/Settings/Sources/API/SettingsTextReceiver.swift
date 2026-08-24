// ODTS TASK: https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4

import DataStorage
import Foundation

/// State and content errors raised while assembling settings text.
public enum SettingsTextReceiverError: Error, Sendable, Equatable {
    /// Data was delivered or completion requested after successful completion.
    case alreadyFinished
    /// The caller requested text before the stream completed.
    case notFinished
    /// The complete byte sequence is not valid UTF-8.
    case invalidUTF8
}

/// Collects streamed settings bytes and validates their UTF-8 representation.
///
/// Parsing a concrete settings format can later replace or wrap this receiver
/// without changing ResourceAccess or DataStorage. The receiver buffers the
/// complete payload because UTF-8 code points may cross chunk boundaries.
///
/// The actor protects accumulated data and completion state when used by an
/// asynchronous storage operation. A receiver instance represents one stream
/// and cannot be reset or reused after successful completion.
public actor SettingsTextReceiver: DataStreamReceiver {
    private var data = Data()
    private var decodedText: String?
    private var didFinish = false

    /// Creates an empty receiver ready for exactly one settings stream.
    public init() {}

    /// Appends one ordered byte chunk.
    ///
    /// - Parameter chunk: Next bytes supplied by DataStorage. Empty chunks are
    ///   accepted by the receiver even though the standard reader omits them.
    /// - Throws: ``SettingsTextReceiverError/alreadyFinished`` if the stream was
    ///   already completed.
    public func receive(_ chunk: Data) throws {
        guard !didFinish else {
            throw SettingsTextReceiverError.alreadyFinished
        }
        data.append(chunk)
    }

    /// Validates the complete payload as UTF-8 and completes the stream.
    ///
    /// - Throws: ``SettingsTextReceiverError/alreadyFinished`` on repeated
    ///   completion or ``SettingsTextReceiverError/invalidUTF8`` for malformed
    ///   input. Invalid input leaves the receiver unfinished.
    public func finish() throws {
        guard !didFinish else {
            throw SettingsTextReceiverError.alreadyFinished
        }
        guard let text = String(data: data, encoding: .utf8) else {
            throw SettingsTextReceiverError.invalidUTF8
        }

        decodedText = text
        didFinish = true
    }

    /// Returns the validated settings text after completion.
    ///
    /// - Returns: The exact UTF-8 text, including comments and trailing lines.
    /// - Throws: ``SettingsTextReceiverError/notFinished`` until `finish()` has
    ///   completed successfully.
    public func text() throws -> String {
        guard didFinish, let decodedText else {
            throw SettingsTextReceiverError.notFinished
        }
        return decodedText
    }
}
