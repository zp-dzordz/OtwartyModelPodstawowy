import Foundation

extension OMP {
  /// A type that represents structured, generated content.
  ///
  /// Generated content may contain a single value, an array, or key-value pairs with unique keys.
  @available(iOS 13.0, macOS 15.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public struct GeneratedContent: Sendable, Equatable, Generable, CustomDebugStringConvertible {
    
    private var _kind: Kind
    
    /// An instance of the generation schema.
    public static var ompGenerationSchema: GenerationSchema {
      // Minimal, permissive schema for a dynamic GeneratedContent container.
      return GenerationSchema(type: GeneratedContent.self, description: "Dynamic generated content", properties: [])
    }
    
    /// A unique id that is stable for the duration of a generated response.
    ///
    /// A ``LanguageModelSession`` produces instances of `OMP.GeneratedContent` that have a
    /// non-nil `id`. When you stream a response, the `id` is the same for all partial generations in the
    /// response stream.
    ///
    /// Instances of `GeneratedContent` that you produce manually with initializers have a nil `id`
    /// because the framework didn't create them as part of a generation.
    public var id: GenerationID?
    
    /// Creates generated content from another value.
    ///
    /// This is used to satisfy `OMP.Generable.init(_:)
    public init(_ content: OMP.GeneratedContent) throws {
      self = content
    }
    
    /// A representation of this instance.
    public var ompGeneratedContent: GeneratedContent { self }
    
    /// Creates generated content representing a structure with the properties you specify.
    ///
    /// The order of properties is important. For ``OMP.Generable`` types, the order
    /// must match the order properties in the types `schema`.
    public init(
      properties: KeyValuePairs<String, any ConvertibleToGeneratedContent>,
      id: GenerationID? = nil
    ) {
      var dict: [String: GeneratedContent] = [:]
      var keys: [String] = []
      for (k, v) in properties {
        let g = v.ompGeneratedContent
        if dict[k] == nil { keys.append(k) }
        dict[k] = g
      }
      self.init(kind: .structure(properties: dict, orderedKeys: keys), id: id)
    }
    
    /// Creates new generated content from the key-value pairs in the given sequence,
    /// using a combining closure to determine the value for any duplicate keys.
    ///
    /// The order of properties is important. For ``OMP.Generable`` types, the order
    /// must match the order properties in the types `schema`.
    ///
    /// You use this initializer to create generated content when you have a sequence
    /// of key-value tuples that might have duplicate keys. As the content is
    /// built, the initializer calls the `combine` closure with the current and
    /// new values for any duplicate keys. Pass a closure as `combine` that
    /// returns the value to use in the resulting content: The closure can
    /// choose between the two values, combine them to produce a new value, or
    /// even throw an error.
    ///
    /// The following example shows how to choose the first and last values for
    /// any duplicate keys:
    ///
    /// ```swift
    ///     let content = GeneratedContent(
    ///       properties: [("name", "John"), ("name", "Jane"), ("married": true)],
    ///       uniquingKeysWith: { (first, _ in first }
    ///     )
    ///     // GeneratedContent(["name": "John", "married": true])
    /// ```
    ///
    /// - Parameters:
    ///   - properties: A sequence of key-value pairs to use for the new content.
    ///   - id: A unique id associated with GeneratedContent.
    ///   - uniquingKeysWith: A closure that is called with the values for any duplicate
    ///     keys that are encountered. The closure returns the desired value for
    ///     the final content.
    public init<S>(
      properties: S,
      id: GenerationID? = nil,
      uniquingKeysWith combine: (GeneratedContent, GeneratedContent) throws -> some ConvertibleToGeneratedContent
    ) rethrows where S : Sequence, S.Element == (String, any ConvertibleToGeneratedContent) {
      var dict: [String: GeneratedContent] = [:]
      var keys: [String] = []
      
      for (k, v) in properties {
        let newContent = v.ompGeneratedContent
        if let existing = dict[k] {
          dict[k] = try combine(existing, newContent).ompGeneratedContent
        } else {
          dict[k] = newContent
          keys.append(k)
        }
      }
      self.init(kind: .structure(properties: dict, orderedKeys: keys), id: id)
    }
    
    /// Creates content representing an array of elements you specify.
    public init<S>(
      elements: S,
      id: GenerationID? = nil
    ) where S : Sequence, S.Element == any ConvertibleToGeneratedContent {
      let contentArray = elements.map { $0.ompGeneratedContent }
      self.init(kind: .array(contentArray), id: id)
    }
    
    /// Creates content that contains a single value.
    ///
    /// - Parameters:
    ///   - value: The underlying value.
    public init(_ value: some ConvertibleToGeneratedContent) {
      self = value.ompGeneratedContent
    }
    /// Creates content that contains a single value with a custom generation ID.
    ///
    /// - Parameters:
    ///   - value: The underlying value.
    ///   - id: The generation ID for this content.
    public init(_ value: some ConvertibleToGeneratedContent, id: GenerationID) {
      self.init(kind: value.ompGeneratedContent.kind, id: id)
    }

    /// Reads a top level, concrete partially generable type.
    public func value<Value>(_ type: Value.Type = Value.self) throws -> Value where Value: ConvertibleFromGeneratedContent {
      try Value(self)
    }
    
    /// Reads a concrete `Generable` type from named property.
    public func value<Value>(
      _ type: Value.Type = Value.self,
      forProperty property: String
    ) throws -> Value where Value : ConvertibleFromGeneratedContent {
      guard case .structure(let properties, _) = _kind,
            let value = properties[property]
      else {
        throw GeneratedContentError.propertyNotFound(property)
      }
      return try Value(value)
    }
    
    /// Reads an optional, concrete generable type from named property.
    public func value<Value>(
      _ type: Value?.Type = Value?.self,
      forProperty property: String
    ) throws -> Value? where Value : ConvertibleFromGeneratedContent {
      guard case .structure(let properties, _) = _kind else {
        return nil
      }
      guard let value = properties[property] else {
        return nil
      }
      return try Value(value)
    }
    
    /// A string representation for the debug description.
    public var debugDescription: String {
      "GeneratedContent(\(kind))"
    }
    
    /// A Boolean that indicates whether the generated content is completed.
    public var isComplete: Bool {
      switch kind {
      case .null, .bool, .number, .string:
        return true
      case .array(let elements):
        return elements.allSatisfy { $0.isComplete }
      case .structure(let properties, _):
        return properties.values.allSatisfy { $0.isComplete }
      }
    }

    public static func == (a: GeneratedContent, b: GeneratedContent) -> Bool {
      a.kind == b.kind && a.id == b.id
    }
  }
}

public enum GeneratedContentError: Error {
  case propertyNotFound(String)
  case typeMismatch
  case neverCannotBeInstantiated
}

@available(iOS 13.0, macOS 15.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension OMP.GeneratedContent {
  /// A representation of the different types of content that can be stored in `GeneratedContent`.
  ///
  /// `Kind` represents the various types of JSON-compatible data that can be held within
  /// a ``GeneratedContent`` instance, including primitive types, arrays, and structured objects.
  public enum Kind : Equatable, Sendable {
    
    /// Represents a null value.
    case null
    
    /// Represents a boolean value.
    /// - Parameter value: The boolean value.
    case bool(Bool)
    
    /// Represents a numeric value.
    /// - Parameter value: The numeric value as a Double.
    case number(Double)
    
    /// Represents a string value.
    /// - Parameter value: The string value.
    case string(String)
    
    /// Represents an array of `GeneratedContent` elements.
    /// - Parameter elements: An array of ``GeneratedContent`` instances.
    case array([OMP.GeneratedContent])
    
    /// Represents a structured object with key-value pairs.
    /// - Parameters:
    ///   - properties: A dictionary mapping string keys to ``GeneratedContent`` values.
    ///   - orderedKeys: An array of keys that specifies the order of properties.
    case structure(properties: [String : OMP.GeneratedContent], orderedKeys: [String])
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: OMP.GeneratedContent.Kind, b: OMP.GeneratedContent.Kind) -> Bool {
      switch (a, b) {
      case (.null, .null):
        return true
      case (.bool(let lhs), .bool(let rhs)):
        return lhs == rhs
      case (.number(let lhs), .number(let rhs)):
        return lhs == rhs
      case (.string(let lhs), .string(let rhs)):
        return lhs == rhs
      case (.array(let lhs), .array(let rhs)):
        return lhs == rhs
      case (.structure(let lhsProps, let lhsKeys), .structure(let rhsProps, let rhsKeys)):
        return lhsProps == rhsProps && lhsKeys == rhsKeys
      default:
        return false
      }
    }
  }
  
  /// Creates a new `GeneratedContent` instance with the specified kind and `GenerationID`.
  ///
  /// This initializer provides a convenient way to create content from its kind representation.
  ///
  /// - Parameters:
  ///   - kind: The kind of content to create.
  ///   - id: An optional ``GenerationID`` to associate with this content.
  public init(kind: OMP.GeneratedContent.Kind, id: OMP.GenerationID? = nil) {
    self._kind = kind
    self.id = id
  }
  
  /// The kind representation of this generated content.
  ///
  /// This property provides access to the content in a strongly-typed enum representation,
  /// preserving the hierarchical structure of the data and the  data's ``GenerationID`` ids.
  public var kind: OMP.GeneratedContent.Kind {
    return _kind
  }
}

