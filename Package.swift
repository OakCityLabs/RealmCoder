// swift-tools-version:5.1

//
//  RealmCodable.swift
//  RealmCoder
//
//  Created by Jay Lyerly on 10/9/19.
//  Copyright © 2019 Oak City Labs. All rights reserved.
//
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RealmCoder",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "RealmCoder",
            targets: ["RealmCoder"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        // .package(url: "https://github.com/realm/SwiftLint.git", from: "0.31.0"),
        .package(
            url: "https://github.com/realm/realm-cocoa.git",
            from: "4.4.1"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which
        // this package depends on.
        .target(
            name: "RealmCoder",
            dependencies: ["RealmSwift"]),
        .testTarget(
            name: "RealmCoderTests",
            dependencies: ["RealmCoder"])
    ],
    swiftLanguageVersions: [.version("5")]
)
