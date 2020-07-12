// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Sublimate",
    products: [
        .library(
            name: "Sublimate",
            targets: ["Sublimate"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.3.0"),
        .package(url: "https://github.com/vapor/fluent", from: "4.0.0"),
        .package(url: "https://github.com/vapor/sql-kit.git", from: "3.1.0")
    ],
    targets: [
        .target(
            name: "Sublimate",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "SQLKit", package: "sql-kit")
            ],
            path: "Sources"),
        .testTarget(
            name: "Tests",
            dependencies: ["Sublimate"],
            path: "Tests"),
    ]
)

package.platforms = [
   .macOS(.v10_15)
]
