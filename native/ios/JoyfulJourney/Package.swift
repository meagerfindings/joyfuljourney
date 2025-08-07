// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "JoyfulJourney",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "JoyfulJourney",
            targets: ["JoyfulJourney"])
    ],
    dependencies: [
        .package(url: "https://github.com/hotwired/turbo-ios", from: "7.1.0")
    ],
    targets: [
        .target(
            name: "JoyfulJourney",
            dependencies: [
                .product(name: "Turbo", package: "turbo-ios")
            ])
    ]
)