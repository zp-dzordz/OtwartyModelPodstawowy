extension OMP {
  public protocol LanguageModel: Sendable {
    associatedtype UnavailableReason
    
    var availability: Availability<UnavailableReason> { get }
    
    func prewarm(
      for session: LanguageModelSession,
      promptPrefix: Prompt?
    )
    
    func respond<Content>(
      within session: LanguageModelSession,
      to prompt: Prompt,
      generating type: Content.Type,
      includeSchemaInPrompt: Bool,
      options: GenerationOptions
    ) async throws -> LanguageModelSession.Response<Content> where Content: Generable
  }
}

// Mark: - Default Implementation
extension OMP.LanguageModel {
  public var isAvailable: Bool {
    if case .available = availability {
      return true
    } else {
      return false
    }
  }
  
  public func prewarm(
    for session: OMP.LanguageModelSession,
    promptPrefix: OMP.Prompt?
  ) {
    return
  }
}

extension OMP.LanguageModel where UnavailableReason == Never {
  var availability: OMP.Availability<UnavailableReason> {
    return .available
  }
}
