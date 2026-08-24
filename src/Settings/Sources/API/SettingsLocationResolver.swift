// ODTS TASK: https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4

import Foundation

/// Errors raised while determining the platform-specific settings location.
public enum SettingsLocationError: Error, Sendable, Equatable {
    /// The selected platform requires a user directory that is unavailable.
    case missingHomeDirectory(OperatingSystem)
    /// The compiled or explicitly requested platform has no defined mapping.
    case unsupportedOperatingSystem
}

extension SettingsLocationError: LocalizedError {
    /// A user-readable explanation suitable for startup diagnostics.
    public var errorDescription: String? {
        switch self {
        case let .missingHomeDirectory(operatingSystem):
            "No user configuration directory is available for \(operatingSystem.rawValue)."
        case .unsupportedOperatingSystem:
            "The current operating system is not supported."
        }
    }
}

/// Resolves the shared settings location without opening the file.
///
/// Location policy belongs to Settings, while file-system operations belong to
/// ResourceAccess. Calling this type never creates a directory or file.
///
/// Apple platforms use the user Application Support directory. Linux and
/// Android use `XDG_CONFIG_HOME` or fall back to `HOME/.config`. Windows uses
/// `APPDATA`. A base-directory override takes precedence on every platform and
/// is intended for tests or explicitly isolated deployments.
public struct SettingsLocationResolver: Sendable {
    /// Directory name shared by Dokoni ecosystem applications.
    public let applicationIdentifier: String
    private let baseDirectoryOverride: URL?
    private let environment: [String: String]

    /// Creates a platform location resolver.
    ///
    /// - Parameters:
    ///   - applicationIdentifier: Directory identifier appended to the platform
    ///     configuration root.
    ///   - baseDirectoryOverride: Explicit root used before platform policy.
    ///   - environment: Environment snapshot used for XDG, HOME, and APPDATA
    ///     resolution. Capturing it makes behavior deterministic in tests.
    public init(
        applicationIdentifier: String = SettingsDefaults.applicationIdentifier,
        baseDirectoryOverride: URL? = nil,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) {
        self.applicationIdentifier = applicationIdentifier
        self.baseDirectoryOverride = baseDirectoryOverride
        self.environment = environment
    }

    /// Computes the shared settings-file URL for one operating system.
    ///
    /// - Parameter operatingSystem: Platform whose location rules are applied.
    ///   Defaults to ``OperatingSystem/current``.
    /// - Returns: Base directory plus the application identifier and
    ///   ``SettingsDefaults/sharedFileName``.
    /// - Throws: ``SettingsLocationError/missingHomeDirectory(_:)`` when the
    ///   required environment location is absent, or
    ///   ``SettingsLocationError/unsupportedOperatingSystem`` for `unknown`.
    /// - Important: The returned URL may not exist yet.
    public func sharedSettingsFileURL(
        for operatingSystem: OperatingSystem = .current
    ) throws -> URL {
        let baseDirectory = try baseDirectory(for: operatingSystem)
        return baseDirectory
            .appendingPathComponent(applicationIdentifier, isDirectory: true)
            .appendingPathComponent(SettingsDefaults.sharedFileName)
    }

    private func baseDirectory(
        for operatingSystem: OperatingSystem
    ) throws -> URL {
        if let baseDirectoryOverride {
            return baseDirectoryOverride
        }

        switch operatingSystem {
        case .macOS, .iOS:
            if let url = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first {
                return url
            }
            throw SettingsLocationError.missingHomeDirectory(operatingSystem)

        case .linux, .android:
            if let xdgConfigHome = environment["XDG_CONFIG_HOME"],
               !xdgConfigHome.isEmpty {
                return URL(fileURLWithPath: xdgConfigHome, isDirectory: true)
            }
            guard let home = environment["HOME"], !home.isEmpty else {
                throw SettingsLocationError.missingHomeDirectory(operatingSystem)
            }
            return URL(fileURLWithPath: home, isDirectory: true)
                .appendingPathComponent(".config", isDirectory: true)

        case .windows:
            guard let appData = environment["APPDATA"], !appData.isEmpty else {
                throw SettingsLocationError.missingHomeDirectory(operatingSystem)
            }
            return URL(fileURLWithPath: appData, isDirectory: true)

        case .unknown:
            throw SettingsLocationError.unsupportedOperatingSystem
        }
    }
}
