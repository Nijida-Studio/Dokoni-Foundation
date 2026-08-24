// ODTS TASK: https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4

import Foundation

/// The startup information needed to create and read the shared settings file.
public struct SettingsReadPlan: Sendable, Equatable {
    /// Platform used to select the shared configuration root.
    public let operatingSystem: OperatingSystem
    /// Fully resolved location of the shared settings file.
    public let fileURL: URL
    /// Bootstrap bytes to use only if ResourceAccess creates the file.
    public let initialContents: Data
}

/// Creates the settings startup plan. It deliberately does not access the file;
/// ResourceAccess remains responsible for that.
public struct SettingsBootstrapPlanner: Sendable {
    private let locationResolver: SettingsLocationResolver

    /// Creates a planner using the supplied location policy.
    ///
    /// - Parameter locationResolver: Resolver used to compute the shared file
    ///   URL. Inject a configured resolver for isolated tests or deployments.
    public init(locationResolver: SettingsLocationResolver = .init()) {
        self.locationResolver = locationResolver
    }

    /// Creates the immutable input for the startup read workflow.
    ///
    /// - Parameter operatingSystem: Platform whose location policy is applied.
    /// - Returns: A plan containing the platform, resolved URL, and initial
    ///   comment-only file contents.
    /// - Throws: Any error produced by ``SettingsLocationResolver``.
    /// - Important: Planning performs no file or connection operation.
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
