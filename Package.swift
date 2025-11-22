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
      name: "OMPCore",
      targets: ["OMPCore"]),
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
  traits: [
    .trait(name: "MLX"),
    .default(enabledTraits: [])
  ],
  dependencies: [
    .package(url: "https://github.com/ml-explore/mlx-swift-lm", branch: "main")
  ],
  targets: [
    .target(
      name: "OMPCore",
      dependencies: [
        "Schema",
        "SwiftGrammar",
        .product(
            name: "MLXLLM",
            package: "mlx-swift-lm",
            condition: .when(traits: ["MLX"])
        ),
        .product(
            name: "MLXVLM",
            package: "mlx-swift-lm",
            condition: .when(traits: ["MLX"])
        ),
        .product(
            name: "MLXLMCommon",
            package: "mlx-swift-lm",
            condition: .when(traits: ["MLX"])
        )
      ]
    ),
    .testTarget(
      name: "OMPTests",
      dependencies: [
//        .product(
//          name: "MLXLMCommon",
//          package: "mlx-swift-examples"
//        ),
        "OMPCore",
        "Schema",
        "SwiftGrammar"
      ]
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
//        .product(
//          name: "MLXLMCommon",
//          package: "mlx-swift-examples"
//        ),
        "CXGrammarBindings",
        "Schema",
        .product(
            name: "MLXLMCommon",
            package: "mlx-swift-lm",
            condition: .when(traits: ["MLX"])
        )
      ],
      swiftSettings: [
        .strictMemorySafety()
      ]
    ),
    .testTarget(
      name: "SwiftGrammarTests",
      dependencies: [
//        .product(
//          name: "MLX",
//          package: "mlx-swift"
//        ),
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
