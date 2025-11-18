import Foundation

extension OMP {
  /// A type that the model uses when responding to prompts.
  @available(iOS 13.0, macOS 15.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public protocol Generable : ConvertibleFromGeneratedContent, ConvertibleToGeneratedContent {
    
    /// An instance of generation schema
    static var ompGenerationSchema: GenerationSchema { get }
  }
}

