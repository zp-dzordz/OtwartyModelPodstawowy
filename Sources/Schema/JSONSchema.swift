//
//  JSONSchema.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 6/22/19.
//

public struct JSONSchema {
  public let value: Schema
  
  public init(schema: Schema) {
      value = schema
  }
  
  public static func boolean(_ core: CoreContext<JSONTypeFormat.BooleanFormat>) -> Self {
    .init(schema: .boolean(core))
  }

  public enum Schema: Equatable {
    case boolean(CoreContext<JSONTypeFormat.BooleanFormat>)
  }
  
  /// The type and format of the schema.
  public var jsonTypeFormat: JSONTypeFormat? {
    switch value {
    case .boolean(let context):
      return .boolean(context.format)
    }
  }
  
  /// The fundamental type of the schema.
  ///
  /// - Important: "object," "array," "allOf,", "oneOf,"
  ///     "anyOf," "not," "reference," and "undefined" are
  ///     not considered types and such schemas will
  ///     return `nil` for this property.
  public var jsonType: JSONType? {
      return jsonTypeFormat?.jsonType
  }
  
  /// The format of the schema as a string value.
  ///
  /// This can be set even when a schema type has
  /// not be specified. If a type has been specified,
  /// a type-safe format can be used and retrieved
  /// via the `jsonTypeFormat` property.
  public var formatString: String? {
    switch value {
    case .boolean(let context):
      return context.format.rawValue
    }
  }
}

extension JSONSchema: Encodable {
  public func encode(to encoder: Encoder) throws {
    switch value {
    case .boolean(let context):
      try context.encode(to: encoder)
    }
  }
}

extension JSONSchema: Decodable {
  private enum HintCodingKeys: String, CodingKey {
      case type
      case other

      init(stringValue: String) {
          self = Self(rawValue: stringValue) ?? .other
      }
  }
  
  public init(from decoder: Decoder) throws {
    let hintContainer = try decoder.container(keyedBy: HintCodingKeys.self)
    let typeHint = try hintContainer.decodeIfPresent(JSONType.self, forKey: .type)
    if typeHint == .boolean {
      value = .boolean(try CoreContext<JSONTypeFormat.BooleanFormat>(from: decoder))
      return
    }
    fatalError("Unsupported type")
  }
}

extension JSONSchema: Equatable {
  public static func == (lhs: JSONSchema, rhs: JSONSchema) -> Bool {
    lhs.value == rhs.value
  }
}
