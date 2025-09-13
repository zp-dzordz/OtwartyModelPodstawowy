import Foundation

extension OMP {
  @available(iOS 13.0, macOS 14.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  final public class LanguageModelSession {
    @available(iOS 13.0, macOS 14.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public struct Response<Content> where Content: Generable {
      
    }
    
    public init(
      //      model: SystemLanguageModel = .default,
      //      tools: [any Tool] = [],
      instructions: String? = nil
    ) {
      self.instructions = instructions
    }
    
    @discardableResult
    nonisolated final public func respond(to prompt: String, options: GenerationOptions = GenerationOptions()) async throws -> LanguageModelSession.Response<String> {
      return .init()
    }
    
    private var instructions: String?
  }
}

