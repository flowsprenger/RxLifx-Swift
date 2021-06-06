// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RxLifx-Swift",
    products: [
        .library(name: "RxLifx", targets: ["RxLifx"]),
        .library(name: "RxLifxApi", targets: ["RxLifxApi"]),
        .library(name: "LifxDomain", targets: ["LifxDomain"]),
    ],
    dependencies: [
	.package(url: "https://github.com/ReactiveX/RxSwift.git", .exact("6.2.0"))
    ],
    targets: [
        .target(name: "LifxDomain",dependencies: [], path: "LifxDomain/LifxDomain"),
        .testTarget(
            name: "LifxDomainTests",
            dependencies: ["LifxDomain"], path: "LifxDomain/LifxDomainTests"),
	.target(name: "RxLifx",dependencies: ["RxSwift"], path: "RxLifx/RxLifx"),
        .testTarget(
            name: "RxLifxTests",
            dependencies: ["RxLifx", .product(name: "RxTest", package: "RxSwift")], path: "RxLifx/RxLifxTests"),
 	.target(name: "RxLifxApi",dependencies: ["RxSwift", "LifxDomain", "RxLifx"], path: "RxLifxApi/RxLifxApi"),
        .testTarget(
            name: "RxLifxApiTests",
            dependencies: ["RxLifxApi", .product(name: "RxTest", package: "RxSwift")], path: "RxLifxApi/RxLifxApiTests"),

    ]
)
