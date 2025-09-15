// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OtwartyModelPodstawowy",
    platforms: [
      .iOS(.v17),
      .macOS(.v15)
    ],
    products: [
      // Products define the executables and libraries a package produces, making them visible to other packages.
      .library(
        name: "OMP",
        targets: ["OMP"]),
    ],
    dependencies: [
      .package(
        url: "https://github.com/ml-explore/mlx-swift-examples/",
        branch: "main"
      )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "OMP",
            dependencies: [
//              .product(
//                name: "MLX",
//                package: "mlx-swift-examples"
//              ),
              .product(
                name: "MLXLMCommon",
                package: "mlx-swift-examples"
              ),
              .product(
                name: "MLXLLM",
                package: "mlx-swift-examples"
              )
            ]
        ),
        .testTarget(
            name: "OMPTests",
            dependencies: ["OMP"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
