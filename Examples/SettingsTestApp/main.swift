// ODTS TASK: https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4

import DataStorage
import Foundation
import ResourceAccess
import Settings

@main
struct SettingsTestApp {
    static func main() async throws {
        let operatingSystem = OperatingSystem.current
        let override = ProcessInfo.processInfo.environment["DOKONI_SETTINGS_ROOT"]
            .map { URL(fileURLWithPath: $0, isDirectory: true) }
        let resolver = SettingsLocationResolver(
            baseDirectoryOverride: override
        )
        let plan = try SettingsBootstrapPlanner(
            locationResolver: resolver
        ).makeReadPlan(for: operatingSystem)

        let lifetime: ConnectionLifetime =
            CommandLine.arguments.contains("--persistent")
            ? .persistent
            : .operation

        let connector = LocalFileConnector()
        let connection = try await connector.open(
            LocalFileAccessRequest(
                fileURL: plan.fileURL,
                createIfMissing: true,
                initialContents: plan.initialContents,
                lifetime: lifetime
            )
        )
        let receiver = SettingsTextReceiver()
        let dataStorage = try DataStorageReader()

        try await dataStorage.read(from: connection, into: receiver)
        let text = try await receiver.text()
        print(text, terminator: text.hasSuffix("\n") ? "" : "\n")

        // A persistent connection is normally retained by a long-running app.
        // This short-lived command closes it explicitly before process exit.
        if lifetime == .persistent {
            try await connector.closeAllPersistentConnections()
        }
    }
}
