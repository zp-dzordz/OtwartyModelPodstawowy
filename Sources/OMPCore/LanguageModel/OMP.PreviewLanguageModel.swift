extension OMP {
  public struct PreviewLanguageModel: LanguageModel {
    public enum UnavailableReason: Hashable, Sendable {
      case custom(String)
    }
    
    var availabilityProvider: @Sendable () -> Availability<UnavailableReason>
    var responseProvider: @Sendable (Prompt, GenerationOptions) async throws -> String
    
    init(_ responseProvider: @escaping @Sendable (Prompt, GenerationOptions) async throws -> String = { _, _ in "Mock response" }
    ) {
      self.availabilityProvider = { .available }
      self.responseProvider = responseProvider
    }
    
    public var availability: OMP.Availability<UnavailableReason> {
      return availabilityProvider()
    }
    
    public func respond<Content>(
      within session: OMP.LanguageModelSession,
      to prompt: OMP.Prompt,
      generating type: Content.Type,
      includeSchemaInPrompt: Bool,
      options: OMP.GenerationOptions
    ) async throws -> OMP.LanguageModelSession.Response<Content> where Content : OMP.Generable {
      // For now, only String is supported
      guard type == String.self else {
        fatalError("PreviewLanguageModel only supports generating String content")
      }
      
      let promptWithInstructions = Prompt("Instructions: \(session.instructions?._internal ?? "N/A")\n\(prompt)")
      let text = try await responseProvider(promptWithInstructions, options)
      
      let responseEntry = Transcript.Entry.response(
        Transcript.Response(
          assetIDs: [],
          segments: [.text(.init(content: text))]
        )
      )
      
      return LanguageModelSession.Response(
        content: text as! Content,
        rawContent: GeneratedContent(text),
        transcriptEntries: [responseEntry])
    }
  }
}

extension OMP.PreviewLanguageModel {
  static var echo: Self {
    OMP.PreviewLanguageModel { prompt, _ in
      prompt._internal
    }
  }
  
  static func fixed(_ response: String) -> Self {
    OMP.PreviewLanguageModel { _, _ in response }
  }
  
  static var unavailable: Self {
    var model = OMP.PreviewLanguageModel.echo
    model.availabilityProvider = {
      .unavailable(.custom("PreviewLanguageModel is unavailable"))
    }
    return model
  }
}
