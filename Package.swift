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
      targets: ["Schema"]),
    .library(
      name: "SwiftGrammar",
      targets: ["SwiftGrammar"]),
    .library(
      name: "CXGrammarBindings",
      targets: ["CXGrammarBindings"])
  ],
  dependencies: [
    .package(url: "https://github.com/ml-explore/mlx-swift", from: "0.25.6"),
    .package(
      url: "https://github.com/ml-explore/mlx-swift-examples/",
      branch: "main"
    ),
    .package(url: "https://github.com/apple/swift-async-algorithms",
             branch: "main"),
    
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
    ),
    .target(
      name: "SwiftGrammar",
      dependencies: [
        .product(
          name: "MLX",
          package: "mlx-swift"
        ),
        "Schema",
        "CXGrammarBindings"
      ],
      swiftSettings: [
        .strictMemorySafety()
      ]
    ),
    .testTarget(
      name: "SwiftGrammarTests",
      dependencies: [
        .product(
          name: "MLX",
          package: "mlx-swift"
        ),
        "Schema",
        "SwiftGrammar"
      ]
    ),
    .target(
      name: "CXGrammarBindings",
      exclude: [
        "xgrammar/web",
        "xgrammar/tests",
        "xgrammar/3rdparty/cpptrace",
        "xgrammar/3rdparty/googletest",
        "xgrammar/3rdparty/dlpack/contrib",
        "xgrammar/3rdparty/picojson",
        "xgrammar/cpp/nanobind",
      ],
      cSettings: [
        .headerSearchPath("xgrammar/include"),
        .headerSearchPath("xgrammar/3rdparty/dlpack/include"),
        .headerSearchPath("xgrammar/3rdparty/picojson"),
      ],
      cxxSettings: [
        .unsafeFlags([
          "-Wno-everything",           // Clang: disable all warnings (stronger than -w)
          "-Wno-unused-parameter",     // disable specific ones
          "-Wno-deprecated-declarations"
        ]),
        .headerSearchPath("xgrammar/include"),
        .headerSearchPath("xgrammar/3rdparty/dlpack/include"),
        .headerSearchPath("xgrammar/3rdparty/picojson"),
      ]
    ),
    
  ],
  swiftLanguageModes: [.v6],
  cxxLanguageStandard: .gnucxx17
)
