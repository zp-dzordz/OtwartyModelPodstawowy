import Foundation
import MLXLMCommon

extension OMP {
  /// A type that describes the properties of an object.
  ///
  /// Generation  schemas guide the output of a ``OMP.SystemLanguageModel`` to deterministically
  /// ensure the output is in the desired format.

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
      
      public let name: String
      public let description: String?
      public let typeName: String

      /// Create a property that contains a generable type.
      ///
      /// - Parameters:
      ///   - name: The property's name.
      ///   - description: A natural language description of what content
      ///     should be generated for this property.
      ///   - type: The type this property represents.
      public init<Value>(name: String, description: String? = nil, type: Value.Type) where Value : Generable {
        self.name = name
        self.description = description
        self.typeName = String(reflecting: type)
      }
      
      /// Create an optional property that contains a generable type.
      ///
      /// - Parameters:
      ///   - name: The property's name.
      ///   - description: A natural language description of what content
      ///     should be generated for this property.
      ///   - type: The type this property represents.
      public init<Value>(name: String, description: String? = nil, type: Value?.Type) where Value : Generable {
        self.name = name
        self.description = description
        self.typeName = String(reflecting: type)
      }
    }
    /// A string representation of the debug description.
    ///
    /// This string is not localized and is not appropriate for display to end users.
    public var debugDescription: String {
      var parts: [String] = []
      parts.append("type: \(typeName)")
      if let props = _properties { parts.append("props: [\(props.map { $0.name }.joined(separator: ", "))]") }
      if let choices = _choices { parts.append("choices: \(choices)") }
      if let anyOf = _anyOfTypes { parts.append("anyOf: [\(anyOf.joined(separator: ", "))]") }
      return "<GenerationSchema \(parts.joined(separator: " | "))>"
    }
    
    private let typeName: String
    private let _properties: [GenerationSchema.Property]?
    private let _choices: [String]?
    private let _anyOfTypes: [String]?
    private let descriptionText: String?

    /// Creates a schema by providing an array of properties.
    ///
    /// - Parameters:
    ///   - type: The type this schema represents.
    ///   - description: A natural language description of this schema.
    ///   - properties: An array of properties.
    public init(type: any Generable.Type, description: String? = nil, properties: [GenerationSchema.Property]) {
      self.typeName = String(reflecting: type)
      self.descriptionText = description
      self._properties = properties
      self._choices = nil
      self._anyOfTypes = nil
    }
    
    /// Creates a schema for a string enumeration.
    ///
    /// - Parameters:
    ///   - type: The type this schema represents.
    ///   - description: A natural language description of this schema.
    ///   - anyOf: The allowed choices.
    public init(type: any Generable.Type, description: String? = nil, anyOf choices: [String]) {
      self.typeName = String(reflecting: type)
      self.descriptionText = description
      self._choices = choices
      self._properties = nil
      self._anyOfTypes = nil
    }
    
    /// Creates a schema as the union of several other types.
    ///
    /// - Parameters:
    ///   - type: The type this schema represents.
    ///   - description: A natural language description of this schema.
    ///   - anyOf: The types this schema should be a union of.
    public init(type: any Generable.Type, description: String? = nil, anyOf types: [any Generable.Type]) {
      self.typeName = String(reflecting: type)
      self.descriptionText = description
      self._anyOfTypes = types.map { String(reflecting: $0) }
      self._properties = nil
      self._choices = nil
    }
    
    /// A error that occurs when there is a problem creating a generation schema.
    @available(iOS 13.0, macOS 15.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public enum SchemaError : Error, LocalizedError {
      
      /// The context in which the error occurred.
      @available(iOS 13.0, macOS 15.0, *)
      @available(tvOS, unavailable)
      @available(watchOS, unavailable)
      public struct Context : Sendable {
        
        /// A string representation of the debug description.
        ///
        /// This string is not localized and is not appropriate for display to end users.
        public let debugDescription: String
        
        public init(debugDescription: String) {
          self.debugDescription = debugDescription
        }
      }
      
      /// An error that represents an attempt to construct a schema from dynamic schemas,
      /// and two or more of the subschemas have the same type name.
      case duplicateType(schema: String?, type: String, context: GenerationSchema.SchemaError.Context)
      
      /// An error that represents an attempt to construct a dynamic schema
      /// with properties that have conflicting names.
      case duplicateProperty(schema: String, property: String, context: GenerationSchema.SchemaError.Context)
      
      /// An error that represents an attempt to construct an anyOf schema with an
      /// empty array of type choices.
      case emptyTypeChoices(schema: String, context: GenerationSchema.SchemaError.Context)
      
      /// An error that represents an attempt to construct a schema from dynamic schemas,
      /// and one of those schemas references an undefined schema.
      case undefinedReferences(schema: String?, references: [String], context: GenerationSchema.SchemaError.Context)
      
      /// A string representation of the error description.
      public var errorDescription: String? {
        switch self {
        case .duplicateType(let schema, let type, let ctx):
          return "Duplicate type '\(type)' in schema '\(schema ?? "<unknown>")'. Context: \(ctx.debugDescription)"
        case .duplicateProperty(let schema, let property, let ctx):
          return "Duplicate property '\(property)' in schema '\(schema)'. Context: \(ctx.debugDescription)"
        case .emptyTypeChoices(let schema, let ctx):
          return "Empty type choices for schema '\(schema)'. Context: \(ctx.debugDescription)"
        case .undefinedReferences(let schema, let refs, let ctx):
          return "Undefined references \(refs) in schema '\(schema ?? "<unknown>")'. Context: \(ctx.debugDescription)"
        }
      }
      
      /// A suggestion that indicates how to handle the error.
      public var recoverySuggestion: String? {
        switch self {
        case .duplicateType(_ , _, _):
          return "Ensure distinct type names when constructing dynamic schemas."
        case .duplicateProperty(_ , _, _):
          return "Rename or remove duplicate properties in schema construction."
        case .emptyTypeChoices(_, _):
          return "Provide at least one type choice for an anyOf schema."
        case .undefinedReferences(_, _, _):
          return "Provide definitions for referenced schemas or remove the references."
        }
      }
    }
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: any Decoder) throws {
      let c = try decoder.container(keyedBy: CodingKeys.self)
      self.typeName = try c.decodeIfPresent(String.self, forKey: .typeName) ?? "<unknown>"
      self.descriptionText = try c.decodeIfPresent(String.self, forKey: .descriptionText)
      self._properties = try c.decodeIfPresent([GenerationSchema.Property].self, forKey: .properties)
      self._choices = try c.decodeIfPresent([String].self, forKey: .choices)
      self._anyOfTypes = try c.decodeIfPresent([String].self, forKey: .anyOfTypes)
    }

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: any Encoder) throws {
      var c = encoder.container(keyedBy: CodingKeys.self)
      try c.encode(typeName, forKey: .typeName)
      try c.encodeIfPresent(descriptionText, forKey: .descriptionText)
      try c.encodeIfPresent(_properties, forKey: .properties)
      try c.encodeIfPresent(_choices, forKey: .choices)
      try c.encodeIfPresent(_anyOfTypes, forKey: .anyOfTypes)
    }

    private enum CodingKeys: String, CodingKey {
      case typeName, descriptionText, properties, choices, anyOfTypes
    }
  }
}

extension OMP.GenerationSchema.Property: Codable {}
