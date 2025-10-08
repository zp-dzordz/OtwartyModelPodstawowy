extension OMP {
  /// A type that can be converted to generated content.
  @available(iOS 13.0, macOS 15.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public protocol ConvertibleToGeneratedContent {
    /// An instance that represents the generated content.
    var ompGeneratedContent: GeneratedContent { get }
  }
}
