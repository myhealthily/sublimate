// swift-tools-version:5.2

import PackageDescription

let name = "Sublimate"

let package = Package(
    name: name,
    products: [
        .library(
            name: name,
            targets: [name]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.3.0"),
        .package(url: "https://github.com/vapor/fluent", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-kit", from: "1.7.0"),
        .package(url: "https://github.com/vapor/sql-kit.git", from: "3.1.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: name,
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "SQLKit", package: "sql-kit")
            ],
            path: "Sources"),
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
