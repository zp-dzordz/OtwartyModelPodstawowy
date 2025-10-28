import Foundation
import MLXLMCommon
import Schema

extension Bool: OMP.Generable {
  public static var ompGenerationSchema: OMP.GenerationSchema {
    .init(
      type: Bool.self,
      description: nil,
      properties: []
    )
  }
  
  public init(_ content: OMP.GeneratedContent) throws {
    self = try content.value(Bool.self)
  }
  
  public var ompGeneratedContent: OMP.GeneratedContent {
    OMP.GeneratedContent(self)
  }
}

//enum OMPKind: OMP.Generable {
//  init(_ content: OMP.GeneratedContent) throws {
//    fatalError()
//  }
//  
//  var ompGeneratedContent: OMP.GeneratedContent {
//    fatalError()
//  }
//  
//  case sightseeing
//  case foodAndDining
//  case shopping
//  case hotelAndLodging
//  
//  nonisolated static var ompGenerationSchema: OMP.GenerationSchema {
//    OMP.GenerationSchema(type: Self.self, anyOf: ["sightseeing", "foodAndDining", "shopping", "hotelAndLodging"])
//  }
//}





extension OMP {
  /// A type that describes the properties of an object.
  ///
  /// Generation  schemas guide the output of a ``OMP.SystemLanguageModel`` to deterministically
  /// ensure the output is in the desired format.

  public struct GenerationSchema : Codable, CustomDebugStringConvertible {
    /// A property that belongs to a generation schema.
    ///
    /// Fields are named members of object types. Fields are strongly
    /// typed and have optional descriptions and guides.
    public struct Property : Sendable {
      /// Create a property that contains a generable type.
      ///
      /// - Parameters:
      ///   - name: The property's name.
      ///   - description: A natural language description of what content
      ///     should be generated for this property.
      ///   - type: The type this property represents.
      public init<Value>(
        name: String,
        description: String? = nil,
        type: Value.Type,
        guides: [GenerationGuide<Value>] = []
      ) where Value : Generable {
        self.name = name
        self.description = description
        self.typeName = String(reflecting: Value.self)
        self.guidesDescription = guides.map {
          String(describing: $0)
        }
      }
      /// Create an optional property that contains a generable type.
      ///
      /// - Parameters:
      ///   - name: The property's name.
      ///   - description: A natural language description of what content
      ///     should be generated for this property.
      ///   - type: The type this property represents.
      public init<Value>(
        name: String,
        description: String? = nil,
        type: Value?.Type,
        guides: [GenerationGuide<Value>] = []
      ) where Value : Generable {
        self.name = name
        self.description = description
        self.typeName = String(reflecting: Value?.self)
        self.guidesDescription = guides.map { String(describing: $0) }
      }
      
      private let name: String
      private let description: String?
      private let typeName: String
      private let guidesDescription: [String]
    }
    /// A string representation of the debug description.
    ///
    /// This string is not localized and is not appropriate for display to end users.
    public var debugDescription: String {
      fatalError()
    }
    /// Creates a schema by providing an array of properties.
    ///
    /// - Parameters:
    ///   - type: The type this schema represents.
    ///   - description: A natural language description of this schema.
    ///   - properties: An array of properties.
    public init(type: any Generable.Type, description: String? = nil, properties: [GenerationSchema.Property]) {
      if type == Bool.self {
        _internalRepresentation = JSONSchema.boolean(.init(format: .unspecified, required: true))
      } else {
        fatalError()
      }
    }
    
    /// Creates a schema for a string enumeration.
    ///
    /// - Parameters:
    ///   - type: The type this schema represents.
    ///   - description: A natural language description of this schema.
    ///   - anyOf: The allowed choices.
    public init(type: any Generable.Type, description: String? = nil, anyOf choices: [String]) {
      fatalError()
    }
    
    /// Creates a schema as the union of several other types.
    ///
    /// - Parameters:
    ///   - type: The type this schema represents.
    ///   - description: A natural language description of this schema.
    ///   - anyOf: The types this schema should be a union of.
    public init(type: any Generable.Type, description: String? = nil, anyOf types: [any Generable.Type]) {
        fatalError()
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
      fatalError()
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
      
    }

    private let _internalRepresentation: JSONSchema
  }
}

// GenerationSchema is Sendable, but unchecked due to property
extension JSONSchema: @unchecked Sendable {}
