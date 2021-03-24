// swift-tools-version:5.2

import PackageDescription

let name = "Sublimate"

let package = Package(
    name: name,
    products: [
        .library(
            name: name,
            targets: [name]),
        .library(
            name: "\(name)FluentKit",
            targets: ["\(name)FluentKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.3.0"),
        .package(url: "https://github.com/vapor/fluent-kit", from: "1.7.0"),
        .package(url: "https://github.com/vapor/fluent", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
        .package(url: "https://github.com/apple/swift-nio", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: name,
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .target(name: "\(name)FluentKit"),
            ]),
        .target(
            name: "\(name)FluentKit",
            dependencies: [
                .target(name: "\(name)NIO"),
                .product(name: "FluentKit", package: "fluent-kit"),
                .product(name: "FluentSQL", package: "fluent-kit"),
            ]),
        .target(
            name: "\(name)NIO",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
            ]),

        .testTarget(
            name: "Tests",
            dependencies: [
                .target(name: name),
                .product(name: "XCTFluent", package: "fluent-kit"),
                .product(name: "XCTVapor", package: "vapor"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver")
            ],
            path: "Tests"),
    ]
)

package.platforms = [
   .macOS(.v10_15)
]
