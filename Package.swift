// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MyLaunchpad",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "MyLaunchpad",
            path: "Sources"
        )
    ]
)
