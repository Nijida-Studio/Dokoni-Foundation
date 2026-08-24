import Foundation
import ResourceAccess
import XCTest

final class LocalFileConnectorTests: XCTestCase {
    func testFirstOpenCreatesDirectoryAndFile() async throws {
        let temporaryDirectory = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: temporaryDirectory) }
        let fileURL = temporaryDirectory
            .appendingPathComponent("nested", isDirectory: true)
            .appendingPathComponent("settings.conf")
        let initialContents = Data("# initial\n".utf8)
        let connector = LocalFileConnector()

        let connection = try await connector.open(
            LocalFileAccessRequest(
                fileURL: fileURL,
                createIfMissing: true,
                initialContents: initialContents
            )
        )

        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
        XCTAssertEqual(try Data(contentsOf: fileURL), initialContents)
        try await connection.close()
    }

    func testPersistentOpenReusesConnectionUntilExplicitClose() async throws {
        let temporaryDirectory = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: temporaryDirectory) }
        let fileURL = temporaryDirectory.appendingPathComponent("settings.conf")
        let connector = LocalFileConnector()
        let request = LocalFileAccessRequest(
            fileURL: fileURL,
            createIfMissing: true,
            lifetime: .persistent
        )

        let first = try await connector.open(request)
        let second = try await connector.open(request)

        XCTAssertTrue(first === second)
        let isClosedBeforeExplicitClose = await first.isClosed
        XCTAssertFalse(isClosedBeforeExplicitClose)

        try await connector.closePersistentConnection(for: fileURL)

        let isClosedAfterExplicitClose = await first.isClosed
        XCTAssertTrue(isClosedAfterExplicitClose)
    }

    func testOperationOpenReturnsIndependentConnections() async throws {
        let temporaryDirectory = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: temporaryDirectory) }
        let fileURL = temporaryDirectory.appendingPathComponent("settings.conf")
        let connector = LocalFileConnector()
        let request = LocalFileAccessRequest(
            fileURL: fileURL,
            createIfMissing: true,
            lifetime: .operation
        )

        let first = try await connector.open(request)
        let second = try await connector.open(request)

        XCTAssertFalse(first === second)
        try await first.close()
        try await second.close()
    }

    func testBusyPersistentConnectionRemainsManagedAfterCloseFails() async throws {
        let temporaryDirectory = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: temporaryDirectory) }
        let fileURL = temporaryDirectory.appendingPathComponent("settings.conf")
        let connector = LocalFileConnector()
        let connection = try await connector.open(
            LocalFileAccessRequest(
                fileURL: fileURL,
                createIfMissing: true,
                lifetime: .persistent
            )
        )
        try await connection.beginReading()

        do {
            try await connector.closePersistentConnection(for: fileURL)
            XCTFail("Expected closing a busy connection to fail.")
        } catch {
            XCTAssertEqual(
                error as? ResourceAccessError,
                .connectionBusy(fileURL.standardizedFileURL)
            )
        }

        await connection.endReading()
        let reopened = try await connector.open(
            LocalFileAccessRequest(
                fileURL: fileURL,
                lifetime: .persistent
            )
        )
        XCTAssertTrue(connection === reopened)

        try await connector.closeAllPersistentConnections()
        let isClosed = await connection.isClosed
        XCTAssertTrue(isClosed)
    }

    func testMissingFileFailsWhenCreationIsDisabled() async throws {
        let temporaryDirectory = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: temporaryDirectory) }
        let fileURL = temporaryDirectory.appendingPathComponent("missing.conf")
        let connector = LocalFileConnector()

        do {
            _ = try await connector.open(
                LocalFileAccessRequest(fileURL: fileURL)
            )
            XCTFail("Expected opening a missing file to fail.")
        } catch {
            XCTAssertEqual(
                error as? ResourceAccessError,
                .resourceDoesNotExist(fileURL.standardizedFileURL)
            )
        }
    }

    private func makeTemporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
    }
}
