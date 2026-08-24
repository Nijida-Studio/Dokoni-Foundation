import Foundation

/// The startup information needed to create and read the shared settings file.
public struct SettingsReadPlan: Sendable, Equatable {
    public let operatingSystem: OperatingSystem
    public let fileURL: URL
    public let initialContents: Data
}

/// Creates the settings startup plan. It deliberately does not access the file;
/// ResourceAccess remains responsible for that.
public struct SettingsBootstrapPlanner: Sendable {
    private let locationResolver: SettingsLocationResolver

    public init(locationResolver: SettingsLocationResolver = .init()) {
        self.locationResolver = locationResolver
    }

    public func makeReadPlan(
        for operatingSystem: OperatingSystem = .current
    ) throws -> SettingsReadPlan {
        SettingsReadPlan(
            operatingSystem: operatingSystem,
            fileURL: try locationResolver.sharedSettingsFileURL(
                for: operatingSystem
            ),
            initialContents: SettingsDefaults.initialFileContents
        )
    }
}
