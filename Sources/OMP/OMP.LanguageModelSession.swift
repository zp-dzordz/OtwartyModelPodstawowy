import AsyncAlgorithms
import Foundation
import MLX
import MLXLMCommon

extension OMP {
  @available(iOS 13.0, macOS 15.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public struct Prompt : Sendable {
  }
}

extension OMP {
  @available(iOS 13.0, macOS 15.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  final public class LanguageModelSession {
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
    
    public convenience init(
      model: SystemLanguageModel = .default,
      instructions: String? = nil
    ) {
      self.init(
        model: model,
        tools: [],
        instructions: instructions
      )
    }
    
    private init(
      model: SystemLanguageModel,
      tools: [any Tool] = [],
      instructions: String? = nil,
    ) {
      self.model = model
      self.instructions = instructions
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
    
    private var output = ""
    private var instructions: String?
    private var model: SystemLanguageModel
    private var container: ModelContainer?
  }
}

@available(iOS 13.0, macOS 15.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension OMP.LanguageModelSession: @unchecked Sendable {}
