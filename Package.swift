// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KidsBank",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "KidsBank",
            targets: ["KidsBank"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.9.0")
    ],
    targets: [
        .target(
            name: "KidsBank",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "KidsBank/KidsBank",
            exclude: [
                "KidsBank.entitlements",
                "Preview Content/Preview Assets.xcassets",
                "Assets.xcassets"
            ]
        )
    ]
)
