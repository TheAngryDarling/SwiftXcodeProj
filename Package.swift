// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let package = Package(
    name: "XcodeProj",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "XcodeProj",
            targets: ["XcodeProj"]),
        .library(
            name: "PBXProj",
            targets: ["PBXProj"]),
        
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/TheAngryDarling/SwiftStringIANACharacterSetEncoding.git", from: "2.0.1"),
        .package(url: "https://github.com/TheAngryDarling/SwiftNillable.git", from: "1.0.3"),
        .package(url: "https://github.com/TheAngryDarling/SwiftCodableHelpers.git", from: "1.0.6"),
        .package(url: "https://github.com/TheAngryDarling/SwiftCodeTimer.git", from: "1.0.0"),
        .package(url: "https://github.com/TheAngryDarling/SwiftClassCollections.git", from: "1.0.0"),
        .package(url: "https://github.com/TheAngryDarling/SwiftVersionKit.git", from: "1.0.3"),
        .package(url: "https://github.com/TheAngryDarling/SwiftPatches.git", from: "0.5.2"),
        .package(url: "https://github.com/TheAngryDarling/SwiftRawRepresentableHelpers.git", from: "0.5.2"),
        //.package(url: "https://github.com/TheAngryDarling/SwiftLeveledCustomStringConvertible.git", from: "1.0.0")
        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "PBXProj",
            dependencies: ["StringIANACharacterSetEncoding", "CodableHelpers", "Nillable", "CodeTimer", "SwiftPatches", "RawRepresentableHelpers", "SwiftClassCollections"]),
        .testTarget(
            name: "PBXProjTests",
            dependencies: ["PBXProj"]),
        
        .target(
            name: "XcodeProj",
            dependencies: ["PBXProj", "CodableHelpers", "CodeTimer", "RawRepresentableHelpers", "VersionKit"]),
        .testTarget(
            name: "XcodeProjTests",
            dependencies: ["XcodeProj", "CodeTimer", "SwiftPatches"]),
    ]
)


