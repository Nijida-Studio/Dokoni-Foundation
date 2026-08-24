import Foundation

/// Stable identifiers and initial content shared by Dokoni ecosystem apps.
public enum SettingsDefaults {
    public static let applicationIdentifier = "de.nijida.dokonie-es"
    public static let sharedFileName = "settings.conf"

    public static var initialFileContents: Data {
        Data(initialText.utf8)
    }

    public static let initialText = """
    # Dokoni ecosystem shared settings
    # Identifier: de.nijida.dokonie-es
    # This file was created automatically and is intentionally otherwise empty.

    """
}
