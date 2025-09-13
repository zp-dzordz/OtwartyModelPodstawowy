extension OMP {
  @available(iOS 13.0, macOS 14.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public protocol ConvertibleToGeneratedContent {
    var generatedContent: GeneratedContent { get }
  }
}
