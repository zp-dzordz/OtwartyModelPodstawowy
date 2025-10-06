import MLXLMCommon
/// A type that describes the properties of an object and any guides
/// on their values.
///
/// Generation  schemas guide the output of a ``OMP.SystemLanguageModel`` to deterministically
/// ensure the output is in the desired format.

extension OMP {
  @available(iOS 13.0, macOS 15.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public struct GenerationSchema : Sendable, Codable, CustomDebugStringConvertible {
    
    public var debugDescription: String {
      "GenerationSchema()"
    }
    
    public init() {}
    /// A property that belongs to a generation schema.
    ///
    /// Fields are named members of object types. Fields are strongly
    /// typed and have optional descriptions and guides.
    @available(iOS 13.0, macOS 15.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public struct Property : Sendable {
      public let name: String
      public let description: String?
      /// Create a property that contains a generable type.
      ///
      /// - Parameters:
      ///   - name: The property's name.
      ///   - description: A natural language description of what content
      ///     should be generated for this property.
      ///   - type: The type this property represents.
      ///   - guides: A list of guides to apply to this property.
      public init<Value>(name: String, description: String? = nil, type: Value.Type/*, guides: [GenerationGuide<Value>] = []*/) where Value : Generable {
        self.name = name
        self.description = description
      }
    }
    
    /// Creates a schema by providing an array of properties.
    ///
    /// - Parameters:
    ///   - type: The type this schema represents.
    ///   - description: A natural language description of this schema.
    ///   - properties: An array of properties.
    public init(type: any Generable.Type, description: String? = nil, properties: [GenerationSchema.Property]) {
        fatalError()
    }
    
    
    /// Creates a schema for a string enumeration.
    ///
    /// - Parameters:
    ///   - type: The type this schema represents.
    ///   - description: A natural language description of this schema.
    ///   - anyOf: The allowed choices.
    public init(type: any Generable.Type, description: String? = nil, anyOf choices: [String]) {
      // Validate : non-empty
      precondition(!choices.isEmpty, "GenerationSchema(anyOf:): choices must not be empty")
      
      // Validate: unique choices (case sensitive). If duplicates collapse or fail; here we assert
      let uniqueChoices = Array(Set(choices))
      precondition(uniqueChoices.count == choices.count, "GenerationSchema(anyOf:): choices must be unique")
      
      // Stora a human-friendly type name for debugging/encoding (use the metatype's) name
      let typename = String(reflecting: type)
      
      // Keep canonical ordering (preserve the original choices order if important)
      // We already validated uniqeness, so simply use choices
//      self.kind = .stringEnum(typeName: typename, description: description, choices: choices)
    }
    
    // MARK: - Codable conformance
    // This encodes the schema as a JSON-like shape similar to many schema formats:
    // { "type": "string", "enum": ["a", "b"], "description": "..." }
    public func encode(to encoder: any Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
//      switch kind {
//      case .stringEnum(_, let description, let choices):
//        try container.encodeIfPresent(description, forKey: .description)
//        try container.encode("string", forKey: .type)
//        try container.encode(choices, forKey: .enumValues)
//      }
    }

    public init(from decoder: any Decoder) throws {
      // Simple decoder that tries to reconstruct string-enum schema
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let decodedType = try container.decodeIfPresent(String.self, forKey: .type)
      if decodedType == "string", let choices = try container.decodeIfPresent([String].self, forKey: .enumValues) {
        let description = try container.decodeIfPresent(String.self, forKey: .description)
        // unknown actual Generable.Type at decode time - use a placeholder type name
//        self.kind = .stringEnum(typeName: "String", description: description, choices: choices)
        return
      }
      
      // TODO - fallback
      fatalError()
    }
    
    // MARK: - Helpers for Codable keys and property encoding
    private enum CodingKeys: String, CodingKey {
      case type
      case description
      case enumValues = "enum"
      case properties
      case anyOf = "anyOf"
    }
  }
}

