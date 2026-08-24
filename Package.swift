// swift-tools-version: 6.0
// ODTS TASK: https://github.com/Nijida-Studio/Dokoni-Foundation/issues/4

import PackageDescription

let package = Package(
    name: "DokoniFoundation",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "ResourceAccess", targets: ["ResourceAccess"]),
        .library(name: "DataStorage", targets: ["DataStorage"]),
        .library(name: "Settings", targets: ["Settings"]),
        .executable(name: "settings-test-app", targets: ["SettingsTestApp"])
    ],
    targets: [
        .target(
            name: "ResourceAccess",
            path: "src/ResourceAccess/Sources",
            exclude: ["ResourceAccess.docc"]
        ),
        .target(
            name: "DataStorage",
            dependencies: ["ResourceAccess"],
            path: "src/DataStorage/Sources",
            exclude: ["DataStorage.docc"]
        ),
        .target(
            name: "Settings",
            dependencies: ["DataStorage"],
            path: "src/Settings/Sources",
            exclude: ["Settings.docc"]
        ),
        .executableTarget(
            name: "SettingsTestApp",
            dependencies: ["DataStorage", "ResourceAccess", "Settings"],
            path: "Examples/SettingsTestApp"
        ),
        .testTarget(
            name: "ResourceAccessTests",
            dependencies: ["ResourceAccess"],
            path: "Tests/ResourceAccessTests"
        ),
        .testTarget(
            name: "DataStorageTests",
            dependencies: ["DataStorage", "ResourceAccess", "Settings"],
            path: "Tests/DataStorageTests"
        ),
        .testTarget(
            name: "SettingsTests",
            dependencies: ["DataStorage", "ResourceAccess", "Settings"],
            path: "Tests/SettingsTests"
        )
    ]
)
