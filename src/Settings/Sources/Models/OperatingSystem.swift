// ODTS TASK: https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4

/// Operating systems relevant to Foundation startup configuration.
///
/// The value drives settings-location policy; it is not intended as a general
/// platform feature matrix.
public enum OperatingSystem: String, Sendable, Equatable, CaseIterable {
    /// Apple's desktop operating system.
    case macOS
    /// Apple's mobile operating system.
    case iOS
    /// Linux distributions supported by Swift.
    case linux
    /// Microsoft Windows.
    case windows
    /// Android environments supported by Swift.
    case android
    /// A platform for which Settings defines no location policy.
    case unknown

    /// The operating system selected when the current binary was compiled.
    ///
    /// Detection uses Swift conditional compilation rather than runtime host
    /// inspection. An unrecognized target returns ``unknown``.
    public static var current: OperatingSystem {
        #if os(macOS)
        .macOS
        #elseif os(iOS)
        .iOS
        #elseif os(Linux)
        .linux
        #elseif os(Windows)
        .windows
        #elseif os(Android)
        .android
        #else
        .unknown
        #endif
    }
}
