import MLXLMCommon
import Observation

extension OMP {
  @available(iOS 13.0, macOS 15.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public protocol Tool<Arguments, Output> : Sendable {
    /// The output that this tool produces for the language model to reason about in subsequent
    /// interactions.
    ///
    /// Typically output is either a ``String`` or a ``OMP.Generable`` type.
    associatedtype Output : PromptRepresentable
    
    /// The arguments that this tool should accept.
    ///
    /// Typically arguments are either a ``Generable`` type or ``GeneratedContent``.
    associatedtype Arguments : ConvertibleFromGeneratedContent
    
    /// A unique name for the tool, such as "get_weather", "toggleDarkMode", or "search contacts".
    var name: String { get }
    
    /// A natural language description of when and how to use the tool.
    var description: String { get }
    
    /// A schema for the parameters this tool accepts.
    var parameters: OMP.GenerationSchema { get }
    
    /// If true, the model's name, description, and parameters schema will be injected
    /// into the instructions of sessions that leverage this tool.
    ///
    /// The default implementation is `true`
    ///
    /// - Note: This should only be `false` if the model has been trained to have
    /// innate knowledge of this tool. For zero-shot prompting, it should always be `true
    var includesSchemaInInstructions: Bool { get }
    
    /// A language model will call this method when it wants to leverage this tool.
    ///
    /// If errors are throw in the body of this method, they will be wrapped in a
    /// ``LanguageModelSession.ToolCallError`` and rethrown at the call site
    /// of ``LanguageModelSession.respond(to:)``.
    ///
    /// - Note: This method may be invoked concurrently with itself or with other tools.
    func call(arguments: Self.Arguments) async throws -> Self.Output
  }
}

@available(iOS 13.0, macOS 15.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension OMP.Tool {
  public var includesSchemaInInstructions: Bool {
    return true
  }
}


@available(iOS 13.0, macOS 15.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension OMP.Tool where Self.Arguments : OMP.Generable {
  
  /// A schema for the parameters this tool accepts.
  public var parameters: OMP.GenerationSchema {
    fatalError()
  }
}

extension OMP {
  enum Category: String, CaseIterable, Codable {
    case hotel
    case restaurant
    
    nonisolated static var ompGenerationSchema: OMP.GenerationSchema {
      OMP.GenerationSchema(type: Self.self, anyOf: [hotel.rawValue, restaurant.rawValue])
    }
    
    nonisolated var ompGeneratedContent: GeneratedContent {
      rawValue.ompGeneratedContent
    }
  }
}

extension OMP.Category:  nonisolated OMP.Generable {  
  nonisolated init(_ content: OMP.GeneratedContent) throws {
    fatalError()
//    let rawValue = try content.value(String.self)
//    if let value = Self(rawValue: rawValue) {
//      self = value
//    } else {
//      // TODO: Turn into throw
//      fatalError("Unexpected rawValue for \(Self.self)")
//    }
  }
}

// Let's start with trying to prototype with MLX first
extension OMP {
  final class FindPointsOfInterestMLXTool {
    let tool: MLXLMCommon.Tool<Category, String>
    
    init() {
      self.tool = MLXLMCommon.Tool<Category, String>.init(
        name: "findPointsOfInterest",
        description: "Finds points of interest for a landmark.",
        parameters: [
          .required(
            "pointOfInterest",
            type: .string,
            description: "This is the type of business to look up for.",
            extraProperties: [
              "enum": ["hotel", "restaurant"]
            ]
          )
        ],
        handler: { input in
          switch input {
          case .hotel:
            return ["Hotel 1", "Hotel 2", "Hotel 3"][(0..<3).randomElement()!]
          case.restaurant:
            return ["Restaurant 1", "Restaurant 2", "Restaurant 3"][(0..<3).randomElement()!]
          }
        }
      )
    }
  }
}

// Now let's try to map it to OMP.Tool
@available(iOS 13.0, macOS 15.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension OMP {
  @Observable
  final class FindPointOfInterestTool: Tool {
    let name = "findPointsOfInterest"
    let description = "Finds points of interest for a landmark."
    
    let landmark: Landmark
    init(landmark: Landmark) {
      self.landmark = landmark
    }
    
    struct Arguments {
      let pointOfInterest: Category
      nonisolated static var ompGenerationSchema: OMP.GenerationSchema {
        OMP.GenerationSchema(
          type: Self.self,
          properties: [
            OMP.GenerationSchema.Property(
              name: "pointOfInterest",
              description: "This is the type of business to look up for.",
              type: Category.self
            )
          ]
        )
      }
      
      nonisolated var ompGeneratedContent: GeneratedContent {
        fatalError()
//        GeneratedContent(
//          properties: [
//            "pointOfInterest": pointOfInterest
//          ]
//        )
      }
    }
    
    func call(arguments: Arguments) async throws -> String {
      let results = await getSuggestions(category: arguments.pointOfInterest, landmark: landmark.name)
      return """
      There are these \(arguments.pointOfInterest) in \(landmark.name):
      \(results.joined(separator: ", "))
      """
    }

    func getSuggestions(category: Category, landmark: String) async -> [String] {
      switch category {
      case .hotel: ["Hotel 1", "Hotel 2", "Hotel 3"]
      case .restaurant: ["Restaurant 1", "Restaurant 2", "Restaurant 3"]
      }
    }
  }
}

extension OMP.FindPointOfInterestTool.Arguments: nonisolated OMP.Generable {
  nonisolated init(_ content: OMP.GeneratedContent) throws {
    fatalError()
//    self.pointOfInterest = try content.value(OMP.Category.self)
  }
}
