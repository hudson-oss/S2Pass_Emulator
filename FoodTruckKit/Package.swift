// swift-tools-version: 6.0

/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The FoodTruckKit package.
*/

import PackageDescription

let package = Package(
    name: "FoodTruckKit",
    defaultLocalization: "en",
    platforms: [
        .macOS("13.3"),
        .iOS("16.4"),
        .macCatalyst("16.4")
    ],
    products: [
        .library(
            name: "FoodTruckKit",
            targets: ["FoodTruckKit"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-algorithms.git",
            from: "1.2.1"
        ),
        .package(
            url: "https://github.com/Swift-ImmutableData/ImmutableData-Legacy.git",
            from: "0.3.0"
        ),
    ],
    targets: [
        .target(
            name: "FoodTruckKit",
            dependencies: [
                .product(
                    name: "Algorithms",
                    package: "swift-algorithms"
                ),
                .product(
                    name: "ImmutableData",
                    package: "ImmutableData-Legacy"
                ),
                .product(
                    name: "ImmutableUI",
                    package: "ImmutableData-Legacy"
                ),
            ],
            path: "Sources"
        )
    ],
    swiftLanguageModes: [
        .v5
    ]
)
