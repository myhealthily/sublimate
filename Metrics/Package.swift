// swift-tools-version:5.2
import PackageDescription

let name = "SublimateMetrics"

let package = Package(
    name: name,
    products: [
        .executable(
            name: name,
            targets: [name]),
    ],
    dependencies: [
        .package(name: "Sublimate", path: ".."),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.3.0"),
        .package(url: "https://github.com/vapor/fluent", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-kit", from: "1.4.1"),
        .package(url: "https://github.com/vapor/sql-kit.git", from: "3.1.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0-beta")
    ],
    targets: [
        .target(
            name: name,
            dependencies: [
                .product(name: "Sublimate", package: "Sublimate"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "SQLKit", package: "sql-kit"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "FluentKit", package: "fluent-kit"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver")
            ],
            path: "."),
    ]
)

package.platforms = [
   .macOS(.v10_15)
]
