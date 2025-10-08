import Foundation

extension OMP {
  /// A type that represents structured, generated content.
  ///
  /// Generated content may contain a single value, an array, or key-value pairs with unique keys.
  @available(iOS 13.0, macOS 15.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public struct GeneratedContent: Sendable, Equatable, Generable, CustomDebugStringConvertible {
    
    private enum _Storage: Equatable {
      case null
      case bool(Bool)
      case number(Double)
      case string(String)
      case array([GeneratedContent])
      case object([String: GeneratedContent], order: [String])
    }
    
    private var _storage: _Storage = .null
    private var _isCompleteBacking: Bool = true
    
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
    public var ompGeneratedContent: GeneratedContent {
      self
    }
    
    /// Creates generated content representing a structure with the properties you specify.
    ///
    /// The order of properties is important. For ``OMP.Generable`` types, the order
    /// must match the order properties in the types `schema`.
    public init(properties: KeyValuePairs<String, any ConvertibleToGeneratedContent>, id: GenerationID? = nil) {
      var dict: [String: GeneratedContent] = [:]
      var order: [String] = []
      for (k, v) in properties {
        let g = v.ompGeneratedContent
        if dict[k] == nil { order.append(k) }
        dict[k] = g
      }
      self._storage = .object(dict, order: order)
      self.id = id
      self._isCompleteBacking = true
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
    public init<S>(properties: S, id: GenerationID? = nil, uniquingKeysWith combine: (GeneratedContent, GeneratedContent) throws -> some ConvertibleToGeneratedContent) rethrows where S : Sequence, S.Element == (String, any ConvertibleToGeneratedContent) {
      var dict: [String: GeneratedContent] = [:]
      var order: [String] = []
      for (k, v) in properties {
        let newC = v.ompGeneratedContent
        if let existing = dict[k] {
          let combinedOpaque = try combine(existing, newC)
          dict[k] = combinedOpaque.ompGeneratedContent
        } else {
          dict[k] = newC
          order.append(k)
        }
      }
      self._storage = .object(dict, order: order)
      self.id = id
      self._isCompleteBacking = true
    }
    
    /// Creates content representing an array of elements you specify.
    public init<S>(elements: S, id: GenerationID? = nil) where S : Sequence, S.Element == any ConvertibleToGeneratedContent {
      var arr: [GeneratedContent] = []
      for e in elements { arr.append(e.ompGeneratedContent) }
      self._storage = .array(arr)
      self.id = id
      self._isCompleteBacking = true
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
      var tmp = value.ompGeneratedContent
      tmp.id = id
      self = tmp
    }
    
    
    /// Creates equivalent content from a JSON string.
    ///
    /// The JSON string you provide may be incomplete. This is useful for correctly handling partially generated responses.
    ///
    /// ```swift
    /// struct NovelIdea: Generable {
    ///   let title: String
    /// }
    ///
    /// let partial = #"{"title": "A story of"#
    /// let content = try GeneratedContent(json: partial)
    /// let idea = try NovelIdea(content)
    /// print(idea.title) // A story of
    /// ```
    public init(json: String) throws {
      // Try to parse as proper JSON first. If that fails, aggressively try to trim the end
      // (handles many partially-generated cases) — mark isComplete = false when trimming needed.
      //      func fromAny(_ any: Any) -> GeneratedContent {
      //        switch any {
      //        case is NSNull: return GeneratedContent(properties: [:])
      //        case let s as String: return GeneratedContent(s)
      //        case let b as Bool: return GeneratedContent(b)
      //        case let n as NSNumber:
      //          // NSNumber may represent bool or number; inspect
      //          if CFGetTypeID(n) == CFBooleanGetTypeID() { return GeneratedContent(n.boolValue) }
      //          return GeneratedContent(n.doubleValue)
      //        case let arr as [Any]:
      //          return GeneratedContent(elements: arr.map { (item: Any) -> any ConvertibleToGeneratedContent in
      //            // wrap recursively
      //            return fromAny(item)
      //          })
      //        case let dict as [String: Any]:
      //          let kv = dict.map { ($0.key, fromAny($0.value) as any ConvertibleToGeneratedContent) }
      //          return GeneratedContent(properties: KeyValuePairs(uniqueKeysWithValues: kv))
      //        default:
      //          // Fallback: string representation
      //          return GeneratedContent(String(describing: any))
      //        }
      //      }
      //
      //      if let data = json.data(using: .utf8) {
      //        if let parsed = try? JSONSerialization.jsonObject(with: data, options: []) {
      //          self = fromAny(parsed)
      //          self._isCompleteBacking = true
      //          return
      //        }
      //      }
      //
      //      // Attempt to find a trailing boundary that yields valid JSON by trimming the end.
      //      var trimmed = json
      //      while !trimmed.isEmpty {
      //        if let idx = trimmed.lastIndex(where: { $0 == "}" || $0 == "]" }) {
      //          let candidate = String(trimmed[...idx])
      //          if let d = candidate.data(using: .utf8), let parsed = try? JSONSerialization.jsonObject(with: d, options: []) {
      //            self = fromAny(parsed)
      //            self._isCompleteBacking = candidate == json
      //            return
      //          }
      //        }
      //        trimmed.removeLast()
      //      }
      //
      //      // If nothing parsed, store raw string as incomplete content.
      //      self._storage = .string(json)
      //      self._isCompleteBacking = false
    }
    /// Returns a JSON string representation of the generated content.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// // Object with properties
    /// let content = GeneratedContent(properties: [
    ///     "name": "Johnny Appleseed",
    ///     "age": 30,
    /// ])
    /// print(content.jsonString)
    /// // Output: {"name": "Johnny Appleseed", "age": 30}
    /// ```
    public var jsonString: String {
      func toAny(_ gc: GeneratedContent) -> Any {
        switch gc._storage {
        case .null: return NSNull()
        case .bool(let b): return b
        case .number(let d): return d
        case .string(let s): return s
        case .array(let arr): return arr.map { toAny($0) }
        case .object(let dict, let order):
          var out: [String: Any] = [:]
          for key in order {
            if let v = dict[key] { out[key] = toAny(v) }
          }
          return out
        }
      }
      let any = toAny(self)
      if JSONSerialization.isValidJSONObject(any) {
        if let data = try? JSONSerialization.data(withJSONObject: any, options: []) {
          return String(data: data, encoding: .utf8) ?? "{}"
        }
      } else if let s = any as? String {
        // raw string fallback
        return "\"\(s)\""
      }
      return "{}"
    }
    
    /// A string representation for the debug description.
    public var debugDescription: String {
      return jsonString
    }
    
    /// A Boolean that indicates whether the generated content is completed.
    public var isComplete: Bool {
      return _isCompleteBacking
    }
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: GeneratedContent, b: GeneratedContent) -> Bool {
      // If both have generation ids — use them (model-produced content should compare by id)
      if let aid = a.id, let bid = b.id { return aid == bid }
      // Otherwise compare structural value
      return a._storage == b._storage
    }
  }
}

