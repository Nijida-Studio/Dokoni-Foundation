import DataStorage
import Foundation

public enum SettingsTextReceiverError: Error, Sendable, Equatable {
    case alreadyFinished
    case notFinished
    case invalidUTF8
}

/// Collects streamed settings bytes and validates their UTF-8 representation.
///
/// Parsing a concrete settings format can later replace or wrap this receiver
/// without changing ResourceAccess or DataStorage.
public actor SettingsTextReceiver: DataStreamReceiver {
    private var data = Data()
    private var decodedText: String?
    private var didFinish = false

    public init() {}

    public func receive(_ chunk: Data) throws {
        guard !didFinish else {
            throw SettingsTextReceiverError.alreadyFinished
        }
        data.append(chunk)
    }

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

    public func text() throws -> String {
        guard didFinish, let decodedText else {
            throw SettingsTextReceiverError.notFinished
        }
        return decodedText
    }
}
