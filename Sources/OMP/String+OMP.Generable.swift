@available(iOS 13.0, macOS 14.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension String : OMP.Generable {
  public static var ompGenerationSchema: OMP.GenerationSchema {
    return .init()
  }
  
  public init(_ content: OMP.GeneratedContent) throws {
    self.init()
  }
  public var ompGeneratedContent: OMP.GeneratedContent {
    fatalError()
  }
}

