// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "OtwartyModelPodstawowy",
    platforms: [
      .iOS(.v13),
      .macOS(.v15)
    ],
    products: [
      .library(
        name: "OMP",
        targets: ["OMP"]),
      .library(
        name: "Schema",
        targets: ["Schema"])
    ],
    dependencies: [
      .package(
        url: "https://github.com/ml-explore/mlx-swift-examples/",
        branch: "main"
      ),
      .package(url: "https://github.com/apple/swift-async-algorithms",
               branch: "main")
    ],
    targets: [
        .target(
            name: "OMP",
            dependencies: [
              .product(
                name: "AsyncAlgorithms",
                package: "swift-async-algorithms"
              ),
              .product(
                name: "MLXLMCommon",
                package: "mlx-swift-examples"
              ),
              .product(
                name: "MLXLLM",
                package: "mlx-swift-examples"
              ),
              "Schema"
            ]
        ),
        .testTarget(
            name: "OMPTests",
            dependencies: ["OMP"]
        ),
        .target(
          name: "Schema",
          dependencies: []
        ),
        .testTarget(
          name: "SchemaTests",
          dependencies: ["Schema"]
        )
    ],
    swiftLanguageModes: [.v6]
)
