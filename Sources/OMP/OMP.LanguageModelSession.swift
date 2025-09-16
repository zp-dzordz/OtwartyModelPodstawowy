import Foundation
import MLX
import MLXLMCommon



extension OMP {
  @available(iOS 13.0, macOS 14.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  @MainActor
  final public class LanguageModelSession {
    @available(iOS 13.0, macOS 14.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public struct Response<Content>: Sendable where Content: Generable {
      
    }
    
    public init(
      model: ModelContainer,
      //      tools: [any Tool] = [],
      instructions: String? = nil
    ) {
      self.model = model
      self.instructions = instructions
    }
    
    @discardableResult
    nonisolated final public func respond(to prompt: String, options: GenerationOptions = GenerationOptions()) async throws -> LanguageModelSession.Response<String> {
      MLX.seed(UInt64(Date.timeIntervalSinceReferenceDate * 1000))
      let result = try await model.perform { context in
        let input = try await context.processor.prepare(input: .init(prompt: prompt))
        return try MLXLMCommon.generate(
          input: input,
          parameters: .init(maxTokens: options.maximumResponseTokens, temperature: Float(options.temperature ?? .zero)),
          context: context
        ) { tokens in
          if tokens.count % options.displayEveryNTokens == 0 {
            let text = context.tokenizer.decode(tokens: tokens)
            Task { @MainActor in
              self.output = text
            }
          }
          return .more
        }
      }
      await print(self.output)
      return .init()
    }
    
    private var output = ""
    private var instructions: String?
    private var model: ModelContainer
  }
}

