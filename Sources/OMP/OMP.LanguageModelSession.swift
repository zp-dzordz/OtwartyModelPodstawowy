import AsyncAlgorithms
import Foundation
import MLX
import MLXLMCommon

extension OMP {
  @available(iOS 13.0, macOS 15.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  final public class LanguageModelSession {
    
  /// A Boolean value that indicates a response is being generated.
  ///
  /// - Important: Attempting to call any of the respond methods while
  /// this property is `true` is a programmer error.
    final public private(set) var isResponding: Bool = false
    
    /// Start a new session in blank slate state with string-based instructions.
    ///
    /// - Parameters
    ///   - model: The language model to use for this session.
    ///   - tools: Tools to make available to the model for this session.
    ///   - instructions: Instructions that control the model's behavior.
    public convenience init(model: SystemLanguageModel = .default, tools: [any Tool] = [], instructions: String? = nil) {
      self.init(
        model: model,
        tools: tools,
        instructions: instructions,
        transcript: nil
      )
    }
    
    @available(iOS 13.0, macOS 15.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public struct Response<Content> where Content: Generable {
      /// The response content
      public let content: Content
        
      public init(content: Content) {
        self.content = content
      }
    }
        
    private init(
      model: SystemLanguageModel,
      tools: [any Tool] = [],
      instructions: String? = nil,
      transcript: String? = nil
    ) {
      
      self.model = model
      self.instructions = instructions
      self.tools = tools
    }
    
    final public func prewarm(promptPrefix: Prompt? = nil) {
      let loader = model.loader
      Task {
        try await loader.load()
      }
    }
    
    @discardableResult
    nonisolated final public func respond(to prompt: String, options: GenerationOptions = GenerationOptions()) async throws -> LanguageModelSession.Response<String> {
            
      let container = try await model.loader.load()
      
      // each time you generate you will get something new.
      MLXRandom.seed(UInt64(Date.timeIntervalSinceReferenceDate * 1000))
      
      try await container.perform { context in
        let input = try await context.processor.prepare(input: .init(prompt: prompt))
        let stream = try MLXLMCommon.generate(
          input: input,
          parameters: .init(
            maxTokens: options.maximumResponseTokens,
            temperature: Float(options.temperature ?? .zero)
          ),
          context: context
        )
        var result: String = ""
        // generate and output in batches
        for await batch in stream._throttle(for: options.updateInterval, reducing: Generation.collect) {
          // Collect tokens
          let output = batch.compactMap { $0.chunk }.joined(separator: "")
          if !output.isEmpty {
            result += output
          }
        }
        self.output = result
      }
      return .init(content: output)
    }
    
    private func generate(prompt: String, toolResult: String? = nil) async {
      
      self.output = ""
      var chat: [Chat.Message] = [
        .system("You are a helpful assistant"),
        .user(prompt)
      ]
      
      if let toolResult {
        chat.append(.tool(toolResult))
      }
  
//      let mlxTools = tools.map { ompTool in
//        let tool = MLXLMCommon.Tool(
//          name: ompTool.name,
//          description: ompTool.description,
//          parameters: ompTool.parameters,
//          handler: <#T##(Decodable & Encodable) async throws -> Decodable & Encodable#>
//        )
//      }
      
//      let mlxTools = tools.map { ompTool in
        //        let tool = MLXLMCommon.Tool(
        //          name: ompTool.name,
        //          description: ompTool.description,
        //          parameters: [
        //            ompTool.
        //          ],
        //          handler: <#T##(Decodable & Encodable) async throws -> Decodable & Encodable#>
        //        )
        
//      }

//      let userInput = UserInput(
//        chat: chat,
//        tools: <#T##[ToolSpec]?#>
//      )
      
    }
    
    private var output = ""
    private var instructions: String?
    private var model: SystemLanguageModel
    private var container: ModelContainer?
    private let tools: [any Tool]
  }
}

@available(iOS 13.0, macOS 15.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension OMP.LanguageModelSession: @unchecked Sendable {}
