extension OMP {
  @available(iOS 13.0, macOS 15.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public struct GeneratedContent: Sendable, Equatable, Generable, CustomDebugStringConvertible {
    public static var ompGenerationSchema: GenerationSchema {
      .init()
    }
    
    public var ompGeneratedContent: GeneratedContent {
      get {
        fatalError()
      }
    }
    
    
    public init(_ content: GeneratedContent) throws {
    }
    
    public var debugDescription: String { "" }
  }
}
