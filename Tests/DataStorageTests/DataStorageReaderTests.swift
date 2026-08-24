// ODTS TASK: https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4

import DataStorage
import Foundation
import ResourceAccess
import Settings
import XCTest

final class DataStorageReaderTests: XCTestCase {
    func testReadForwardsEveryChunkAndClosesOperationConnection() async throws {
        let temporaryDirectory = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: temporaryDirectory) }
        let fileURL = temporaryDirectory.appendingPathComponent("data.txt")
        let expected = "one two three four"
        let connector = LocalFileConnector()
        let connection = try await connector.open(
            LocalFileAccessRequest(
                fileURL: fileURL,
                createIfMissing: true,
                initialContents: Data(expected.utf8),
                lifetime: .operation
            )
        )
        let receiver = SettingsTextReceiver()
        let reader = try DataStorageReader(chunkSize: 3)

        try await reader.read(from: connection, into: receiver)

        let receivedText = try await receiver.text()
        let isClosed = await connection.isClosed
        XCTAssertEqual(receivedText, expected)
        XCTAssertTrue(isClosed)
    }

    func testReadLeavesPersistentConnectionOpenForReuse() async throws {
        let temporaryDirectory = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: temporaryDirectory) }
        let fileURL = temporaryDirectory.appendingPathComponent("data.txt")
        let connector = LocalFileConnector()
        let connection = try await connector.open(
            LocalFileAccessRequest(
                fileURL: fileURL,
                createIfMissing: true,
                initialContents: Data("persistent".utf8),
                lifetime: .persistent
            )
        )
        let reader = try DataStorageReader(chunkSize: 4)

        let firstReceiver = SettingsTextReceiver()
        try await reader.read(from: connection, into: firstReceiver)
        let isClosedAfterFirstRead = await connection.isClosed
        XCTAssertFalse(isClosedAfterFirstRead)

        let secondReceiver = SettingsTextReceiver()
        try await reader.read(from: connection, into: secondReceiver)
        let secondText = try await secondReceiver.text()
        XCTAssertEqual(secondText, "persistent")

        try await connector.closeAllPersistentConnections()
        let isClosedAfterExplicitClose = await connection.isClosed
        XCTAssertTrue(isClosedAfterExplicitClose)
    }

    func testReceiverFailureClosesOperationConnection() async throws {
        let temporaryDirectory = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: temporaryDirectory) }
        let fileURL = temporaryDirectory.appendingPathComponent("data.txt")
        let connector = LocalFileConnector()
        let connection = try await connector.open(
            LocalFileAccessRequest(
                fileURL: fileURL,
                createIfMissing: true,
                initialContents: Data("content".utf8),
                lifetime: .operation
            )
        )
        let reader = try DataStorageReader()

        do {
            try await reader.read(
                from: connection,
                into: FailingReceiver()
            )
            XCTFail("Expected receiver failure.")
        } catch {
            XCTAssertEqual(error as? ReceiverTestError, .rejected)
        }

        let isClosed = await connection.isClosed
        XCTAssertTrue(isClosed)
    }

    func testRejectsInvalidChunkSize() {
        XCTAssertThrowsError(try DataStorageReader(chunkSize: 0)) { error in
            XCTAssertEqual(
                error as? DataStorageError,
                .invalidChunkSize(0)
            )
        }
    }

    private func makeTemporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
    }
}

private enum ReceiverTestError: Error {
    case rejected
}

private actor FailingReceiver: DataStreamReceiver {
    func receive(_ chunk: Data) throws {
        throw ReceiverTestError.rejected
    }

    func finish() {}
}
