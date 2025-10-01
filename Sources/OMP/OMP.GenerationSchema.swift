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
  
    /// A property that belongs to a generation schema.
    ///
    /// Fields are named members of object types. Fields are strongly
    /// typed and have optional descriptions and guides.
    @available(iOS 13.0, macOS 15.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public struct Property : Sendable {
      /// Create a property that contains a generable type.
      ///
      /// - Parameters:
      ///   - name: The property's name.
      ///   - description: A natural language description of what content
      ///     should be generated for this property.
      ///   - type: The type this property represents.
      ///   - guides: A list of guides to apply to this property.
      public init<Value>(name: String, description: String? = nil, type: Value.Type/*, guides: [GenerationGuide<Value>] = []*/) where Value : Generable {
        
      }
    }

    public var debugDescription: String { "" }
    
    /// Creates a schema by providing an array of properties.
    ///
    /// - Parameters:
    ///   - type: The type this schema represents.
    ///   - description: A natural language description of this schema.
    ///   - properties: An array of properties.
    public init(type: any Generable.Type, description: String? = nil, properties: [GenerationSchema.Property]) {
    }

    /// Creates a schema for a string enumeration.
    ///
    /// - Parameters:
    ///   - type: The type this schema represents.
    ///   - description: A natural language description of this schema.
    ///   - anyOf: The allowed choices.
    public init(type: any Generable.Type, description: String? = nil, anyOf choices: [String]) {
    }
  }
}

