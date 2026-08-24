/// Operating systems relevant to Foundation startup configuration.
public enum OperatingSystem: String, Sendable, Equatable, CaseIterable {
    case macOS
    case iOS
    case linux
    case windows
    case android
    case unknown

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
