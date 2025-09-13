extension OMP {
  @available(iOS 13.0, macOS 14.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public protocol ConvertibleFromGeneratedContent : SendableMetatype {
    
    /// Creates an instance with the content
    init(_ content: GeneratedContent) throws
  }
}

