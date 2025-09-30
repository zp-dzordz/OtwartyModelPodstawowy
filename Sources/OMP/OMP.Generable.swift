import Foundation

extension OMP {
  @available(iOS 13.0, macOS 15.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public protocol Generable : ConvertibleFromGeneratedContent {
   
    /// A representation of partially generated content
    associatedtype PartiallyGenerated: ConvertibleFromGeneratedContent = Self
    
    /// An instance of generation schema
    static var ompGenerationSchema: GenerationSchema { get }
  }
}

