extension OMP {
  @available(iOS 13.0, macOS 15.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public struct GeneratedContent: Sendable, Equatable, Generable, CustomDebugStringConvertible {
        
    /// An instance of the generation schema.
    public static var ompGenerationSchema: GenerationSchema {
      fatalError()
    }
    
    /// A representation of this instance.
    public var ompGeneratedContent: GeneratedContent {
      get {
        fatalError()
      }
    }
    
    /// Creates generated content representing a structure with the properties you specify.
    ///
    /// The order of properties is important. For ``OMP.Generable`` types, the order
    /// must match the order properties in the types `schema`.
    public init(properties: KeyValuePairs<String, any ConvertibleToGeneratedContent>, id: GenerationID? = nil) {
      
    }

    public init(_ content: GeneratedContent) throws {
    }
    
    /// Reads a top level, concrete partially generable type.
    public func value<Value>(_ type: Value.Type = Value.self) throws -> Value where Value : ConvertibleFromGeneratedContent {
      fatalError()
    }
    
    public var debugDescription: String { "" }
  }
}
