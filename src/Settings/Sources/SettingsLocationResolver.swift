import Foundation

public enum SettingsLocationError: Error, Sendable, Equatable {
    case missingHomeDirectory(OperatingSystem)
    case unsupportedOperatingSystem
}

extension SettingsLocationError: LocalizedError {
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
public struct SettingsLocationResolver: Sendable {
    public let applicationIdentifier: String
    private let baseDirectoryOverride: URL?
    private let environment: [String: String]

    public init(
        applicationIdentifier: String = SettingsDefaults.applicationIdentifier,
        baseDirectoryOverride: URL? = nil,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) {
        self.applicationIdentifier = applicationIdentifier
        self.baseDirectoryOverride = baseDirectoryOverride
        self.environment = environment
    }

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
