import Foundation

/// A transcript contains a linear history of ``Transcript/Entry`` entries.
///
/// Transcript entries are can be used to visualize previous prompts and
/// responses.
///
/// ```swift
/// struct HistoryView: View {
///     let session: LanguageModelSession
///
///     var body: some View {
///         ScrollView {
///             ForEach(session.transcript) { entry in
///                 switch entry {
///                 case let .instructions(instructions):
///                     MyInstructionsView(instructions)
///                 case let .prompt(prompt)
///                     MyPromptView(prompt)
///                 case let .toolCalls(toolCalls):
///                     MyToolCallsView(toolCalls)
///                 case let .toolOutput(toolOutput):
///                     MyToolOutputView(toolOutput)
///                 case let .response(response):
///                     MyResponseView(response)
///                 }
///             }
///         }
///     }
/// }
/// ```
extension OMP {
  @available(iOS 13.0, macOS 15.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public struct Transcript: Sendable, Equatable, RandomAccessCollection {
    
    /// A type that represents a position in the collection.
    ///
    /// Valid indices consist of the position of every element and a
    /// "past the end" position that's not valid for use as a subscript
    /// argument.
    public typealias Index = Int
    
    /// Accesses the element at the specified position.
    ///
    /// The following example accesses an element of an array through its
    /// subscript to print its value:
    ///
    ///     var streets = ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]
    ///     print(streets[1])
    ///     // Prints "Bryant"
    ///
    /// You can subscript a collection with any valid index other than the
    /// collection's end index. The end index refers to the position one past
    /// the last element of a collection, so it doesn't correspond with an
    /// element.
    ///
    /// - Parameter position: The position of the element to access. `position`
    ///   must be a valid index of the collection that is not equal to the
    ///   `endIndex` property.
    ///
    /// - Complexity: O(1)
    public subscript(index: Transcript.Index) -> Transcript.Entry {
      entries[index]
    }
    
    /// The position of the first element in a nonempty collection.
    ///
    /// If the collection is empty, `startIndex` is equal to `endIndex`.
    public var startIndex: Int {
      entries.startIndex
    }
    
    /// The collection's "past the end" position---that is, the position one
    /// greater than the last valid subscript argument.
    ///
    /// When you need a range that includes the last element of a collection, use
    /// the half-open range operator (`..<`) with `endIndex`. The `..<` operator
    /// creates a range that doesn't include the upper bound, so it's always
    /// safe to use with `endIndex`. For example:
    ///
    ///     let numbers = [10, 20, 30, 40, 50]
    ///     if let index = numbers.firstIndex(of: 30) {
    ///         print(numbers[index ..< numbers.endIndex])
    ///     }
    ///     // Prints "[30, 40, 50]"
    ///
    /// If the collection is empty, `endIndex` is equal to `startIndex`.
    public var endIndex: Int {
      entries.endIndex
    }
    
    
    /// An entry in a transcript.
    ///
    /// An individual entry in a transcript may represent instructions from you
    /// to the model, a prompt from a user, tool calls, or a response generated
    /// by the model.
    @available(iOS 13.0, macOS 15.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public enum Entry: Sendable, Identifiable, Equatable {
      /// Instructions, typically provided by you, the developer.
      case instructions(Transcript.Instructions)
      
      /// A prompt, typically sourced from an end user.
      case prompt(Prompt)
      
      /// The stable identity of the entity associated with this instance.
      public var id: String {
        switch self {
        case .instructions(let instructions):
          return instructions.id
        case .prompt(let prompt):
          return prompt.id
        }
      }
    }
    /// Instructions you provide to the model that define its behavior.
    ///
    /// Instructions are typically provided to define the role and behavior of the model. Apple trains the model
    /// to obey instructions over any commands it receives in prompts. This is a security mechanism to help
    /// mitigate prompt injection attacks.
    @available(iOS 13.0, macOS 15.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public struct Instructions : Sendable, Identifiable, Equatable {
      /// The stable identity of the entity associated with this instance.
      public var id: String
      
      /// The content of the instructions, in natural language.
      ///
      /// - Note: Instructions are often provided in English even when the
      /// users interact with the model in another language.
      public var segments: [Segment]
      
      /// A list of tools made available to the model.
      public var toolDefinitions: [ToolDefinition]
      
      /// Initialize instructions by describing how you want the model to
      /// behave using natural language.
      ///
      /// - Parameters:
      ///   - id: A unique identifier for this instructions segment.
      ///   - segments: An array of segments that make up the instructions.
      ///   - toolDefinitions: Tools that the model should be allowed to call.
      public init(
        id: String = UUID().uuidString,
        segments: [Transcript.Segment],
        toolDefinitions: [Transcript.ToolDefinition]
      ) {
        self.id = id
        self.segments = segments
        self.toolDefinitions = toolDefinitions
      }
    }
    
    /// A prompt from the user to the model.
    ///
    /// Prompts typically contain content sourced directly from the user,
    /// though you may choose to augment prompts by interpolating content from
    /// end users into a template that you control.
    @available(iOS 13.0, macOS 15.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public struct Prompt : Sendable, Identifiable, Equatable {
      /// The identifier of the prompt.
      public var id: String
      
      /// Ordered prompt segments.
      public var segments: [Transcript.Segment]
      
      /// Generation options associated with the prompt.
      public var options: GenerationOptions
      
      /// An optional response format that describes the desired output structure.
      public var responseFormat: ResponseFormat?
      
      /// Creates a prompt.
      ///
      /// - Parameters:
      ///   - id: A ``Generable`` type to use as the response format.
      ///   - segments: An array of segments that make up the prompt.
      ///   - options: Options that control how tokens are sampled from the distribution the model produces.
      ///   - responseFormat: A response format that describes the output structure.
      public init(
        id: String = UUID().uuidString,
        segments: [Segment],
        options: GenerationOptions = GenerationOptions(),
        responseFormat: ResponseFormat? = nil
      ) {
        self.id = id
        self.segments = segments
        self.options = options
        self.responseFormat = responseFormat
      }
    }
    
    /// Specifies a response format that the model must conform its output to.
    @available(iOS 13.0, macOS 15.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public struct ResponseFormat : Sendable, Equatable {
      /// A name associated with the response format.
      public var name: String {
        // Extract type name from the schema's debug description
        // This is a best-effort approach
        let desc = schema.debugDescription
        if let range = desc.range(of: "$ref("),
           let endRange = desc.range(of: ")", range: range.upperBound ..< desc.endIndex) {
          let name = desc[range.upperBound ..< endRange.lowerBound]
          return String(name)
        }
        return "response"
      }
      
      /// Creates a response format with type you specify.
      ///
      /// - Parameters:
      ///   - type: A ``Generable`` type to use as the response format.
      public init<Content>(type: Content.Type) where Content : Generable {
        self.schema = Content.ompGenerationSchema
      }
      
      /// Creates a response format with a schema.
      ///
      /// - Parameters:
      ///   - schema: A schema to use as the response format.
      public init(schema: GenerationSchema) {
        self.schema = schema
      }
      
      /// Returns a Boolean value indicating whether two values are equal.
      ///
      /// Equality is the inverse of inequality. For any values `a` and `b`,
      /// `a == b` implies that `a != b` is `false`.
      ///
      /// - Parameters:
      ///   - lhs: A value to compare.
      ///   - rhs: Another value to compare.
      public static func == (a: Transcript.ResponseFormat, b: Transcript.ResponseFormat) -> Bool {
        return a.schema.debugDescription == b.schema.debugDescription
      }
      
      private let schema: GenerationSchema
    }
    
    /// The types of segments that may be included in a transcript entry.
    @available(iOS 13.0, macOS 15.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public enum Segment : Sendable, Identifiable, Equatable {
      /// A segment containing text.
      case text(TextSegment)
      
      /// A segment containing structured content.
      case structure(StructuredSegment)
      
      /// A segment containing an image.
      case image(ImageSegment)
      
      /// The stable identity of the entity associated with this instance.
      public var id: String {
        switch self {
        case .text(let textSegment):
          return textSegment.id
        case .structure(let structuredSegment):
          return structuredSegment.id
        case .image(let imageSegment):
          return imageSegment.id
        }
      }
    }
    
    /// A segment containing text.
    @available(iOS 13.0, macOS 15.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public struct TextSegment : Sendable, Identifiable, Equatable {
      /// The stable identity of the entity associated with this instance.
      public var id: String
      
      public var content: String
      
      public init(id: String = UUID().uuidString, content: String) {
        self.id = id
        self.content = content
      }
    }
    
    /// A segment containing structured content.
    @available(iOS 13.0, macOS 15.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public struct StructuredSegment: Sendable, Identifiable, Equatable {
      /// The stable identity of the entity associated with this instance.
      public var id: String
      
      /// A source that can be used to understand which type content represents.
      public var source: String
      
      /// The content of the segment.
      public var content: GeneratedContent
      
      public init(id: String = UUID().uuidString, source: String, content: GeneratedContent) {
        self.id = id
        self.source = source
        self.content = content
      }
    }
    
    /// A segment that represents an image for multi‑modal prompts and outputs.
    ///
    /// Use this type to include images alongside text and structured content when
    /// constructing `Transcript` entries. Images can be provided as raw data with a
    /// MIME type or by URL.
    @available(iOS 13.0, macOS 15.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public struct ImageSegment: Sendable, Identifiable, Equatable {
      /// The stable identity of the entity associated with this instance.
      public var id: String
      
      /// The source of the image data.
      public let source: Source
      
      /// The origin of an image's content.
      public enum Source: Sendable, Equatable {
        /// Image bytes and their MIME type (for example, `image/jpeg`).
        case data(Data, mimeType: String)
        /// A URL that references an image.
        case url(URL)
      }
    }
    
    /// A definition of a tool.
    @available(iOS 13.0, macOS 15.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public struct ToolDefinition: Sendable, Equatable {
      /// The tool's name.
      public var name: String
      /// A description of how and when to use the tool.
      public var description: String
      
      private let parameters: GenerationSchema
      
      public init(name: String, description: String, parameters: GenerationSchema) {
        self.name = name
        self.description = description
        self.parameters = parameters
      }
      
      public init(tool: some Tool) {
        self.name = tool.name
        self.description = tool.description
        self.parameters = tool.parameters
      }
      
      /// Returns a Boolean value indicating whether two values are equal.
      ///
      /// Equality is the inverse of inequality. For any values `a` and `b`,
      /// `a == b` implies that `a != b` is `false`.
      ///
      /// - Parameters:
      ///   - lhs: A value to compare.
      ///   - rhs: Another value to compare.
      public static func == (a: Transcript.ToolDefinition, b: Transcript.ToolDefinition) -> Bool {
        return a.name == b.name && a.description == b.description && a.parameters.debugDescription == b.parameters.debugDescription
      }
    }
    
    /// Appends a single entry to the transcript.
    mutating func append(_ entry: Entry) {
      entries.append(entry)
    }
    
    /// Appends multiple entries to the transcript.
    mutating func append<S>(contentsOf newEntries: S) where S: Sequence, S.Element == Entry {
      entries.append(contentsOf: newEntries)
    }
    
    private var entries: [Entry]
  }
}


