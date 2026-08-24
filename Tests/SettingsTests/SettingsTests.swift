// ODTS TASK: https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4

import DataStorage
import Foundation
import ResourceAccess
import Settings
import XCTest

final class SettingsTests: XCTestCase {
    func testCurrentOperatingSystemIsMacOSOnMacOS() {
        #if os(macOS)
        XCTAssertEqual(OperatingSystem.current, .macOS)
        #else
        XCTAssertNotEqual(OperatingSystem.current, .unknown)
        #endif
    }

    func testResolverPlacesSharedFileBelowEcosystemIdentifier() throws {
        let base = URL(fileURLWithPath: "/configuration", isDirectory: true)
        let resolver = SettingsLocationResolver(
            baseDirectoryOverride: base
        )

        let result = try resolver.sharedSettingsFileURL(for: .macOS)

        XCTAssertEqual(
            result.path,
            "/configuration/de.nijida.dokonie-es/settings.conf"
        )
    }

    func testLinuxResolverUsesXDGConfigurationDirectory() throws {
        let resolver = SettingsLocationResolver(
            environment: ["XDG_CONFIG_HOME": "/xdg/config"]
        )

        let result = try resolver.sharedSettingsFileURL(for: .linux)

        XCTAssertEqual(
            result.path,
            "/xdg/config/de.nijida.dokonie-es/settings.conf"
        )
    }

    func testFirstStartupCreatesAndReadsCommentedSettingsFile() async throws {
        let temporaryDirectory = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: temporaryDirectory) }
        let plan = try SettingsBootstrapPlanner(
            locationResolver: SettingsLocationResolver(
                baseDirectoryOverride: temporaryDirectory
            )
        ).makeReadPlan(for: .macOS)
        let connector = LocalFileConnector()
        let connection = try await connector.open(
            LocalFileAccessRequest(
                fileURL: plan.fileURL,
                createIfMissing: true,
                initialContents: plan.initialContents
            )
        )
        let receiver = SettingsTextReceiver()

        try await DataStorageReader(chunkSize: 7)
            .read(from: connection, into: receiver)

        let receivedText = try await receiver.text()
        XCTAssertEqual(receivedText, SettingsDefaults.initialText)
        XCTAssertEqual(
            try String(contentsOf: plan.fileURL, encoding: .utf8),
            SettingsDefaults.initialText
        )
    }

    func testExistingSettingsFileIsNeverReplacedByInitialContent() async throws {
        let temporaryDirectory = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: temporaryDirectory) }
        let fileURL = temporaryDirectory.appendingPathComponent("settings.conf")
        try FileManager.default.createDirectory(
            at: temporaryDirectory,
            withIntermediateDirectories: true
        )
        try Data("existing=true\n".utf8).write(to: fileURL)
        let connector = LocalFileConnector()

        let connection = try await connector.open(
            LocalFileAccessRequest(
                fileURL: fileURL,
                createIfMissing: true,
                initialContents: SettingsDefaults.initialFileContents
            )
        )
        let receiver = SettingsTextReceiver()
        try await DataStorageReader()
            .read(from: connection, into: receiver)

        let receivedText = try await receiver.text()
        XCTAssertEqual(receivedText, "existing=true\n")
    }

    func testTextReceiverRejectsInvalidUTF8() async throws {
        let receiver = SettingsTextReceiver()
        try await receiver.receive(Data([0xFF]))

        do {
            try await receiver.finish()
            XCTFail("Expected invalid UTF-8 to fail.")
        } catch {
            XCTAssertEqual(
                error as? SettingsTextReceiverError,
                .invalidUTF8
            )
        }
    }

    private func makeTemporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
    }
}
