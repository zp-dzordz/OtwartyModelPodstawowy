extension OMP {
  @available(iOS 13.0, macOS 15.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public struct GeneratedContent: Sendable, Equatable, Generable, CustomDebugStringConvertible {
        /// An instance of the generation schema.
    public static var ompGenerationSchema: GenerationSchema {
      GenerationSchema()
    }
    public var id: GenerationID?
    
    // Stored representation (for now just a simple enum)
    public enum Kind: Equatable, Sendable {
      case string(String)
      case null
    }
    
    private let _kind: Kind
    
    public init(_ content: OMP.GeneratedContent) throws {
      self = content
    }

    public init(_ value: some ConvertibleToGeneratedContent) {
      self._kind = .string(String(describing: value))
    }
    
    public init(_ value: some ConvertibleToGeneratedContent, id: GenerationID) {
      self._kind = .string(String(describing: value))
      self.id = id
    }
    
    // Dummy variant for simple string literals
    public init(_value: String) {
      self._kind = .string(_value)
    }
    
    // MARK: - ConvertibleToGeneratedContent
    public var ompGeneratedContent: GeneratedContent {
      self
    }
    
    // MARK: - computed properties
    public var jsonString: String {
      switch _kind {
      case .string(let s): return "\"\(s)\""
      case .null: return "null"
      }
    }
    
    public var debugDescription: String { jsonString }
    
    public static func ==(lhs: GeneratedContent, rhs: GeneratedContent) -> Bool {
      lhs.jsonString == rhs.jsonString
    }
    
    public var isComplete: Bool { true }
  }
}
