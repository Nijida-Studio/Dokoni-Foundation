// ODTS TASK: https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4

import Foundation

/// Stable identifiers and initial content shared by Dokoni ecosystem apps.
public enum SettingsDefaults {
    /// Shared directory identifier for every Dokoni ecosystem application.
    public static let applicationIdentifier = "de.nijida.dokonie-es"
    /// Name of the settings file stored directly in the shared directory.
    public static let sharedFileName = "settings.conf"

    /// UTF-8 encoded bootstrap content written when the shared file is absent.
    public static var initialFileContents: Data {
        Data(initialText.utf8)
    }

    /// Human-readable comment block used to initialize an empty settings file.
    ///
    /// It intentionally defines no settings keys. The concrete settings format,
    /// local-versus-remote selection, migration, and secret references remain
    /// future Settings contracts.
    public static let initialText = """
    # Dokoni ecosystem shared settings
    # Identifier: de.nijida.dokonie-es
    # This file was created automatically and is intentionally otherwise empty.

    """
}
