// swift-tools-version: 6.2
import PackageDescription

#if TUIST
import struct ProjectDescription.PackageSettings

let packageSettings = PackageSettings(
    // Customize the product types for specific package product
    // Default is .staticFramework
    // productTypes: ["Alamofire": .framework,]
    productTypes: [
        // Point-Free packages default to static products, and Tuist warns when those products are linked
        // from multiple targets (e.g. app + framework + tests). Use dynamic frameworks to avoid duplicates.
        "Clocks": .framework,
        "CombineSchedulers": .framework,
        "ConcurrencyExtras": .framework,
        "Dependencies": .framework,
        "IssueReporting": .framework,
        "IssueReportingPackageSupport": .framework,
        "XCTestDynamicOverlay": .framework
    ]
)
#endif

let package = Package(
    name: "VanessaGames",
    dependencies: [
        // Add your own dependencies here:
        // .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        // You can read more about dependencies here: https://docs.tuist.io/documentation/tuist/dependencies
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.3"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.6")
    ]
)
