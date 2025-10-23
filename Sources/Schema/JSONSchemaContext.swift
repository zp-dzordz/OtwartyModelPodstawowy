//
//  JSONSchemaContext.swift
//
//
//  Created by Mathew Polzin on 6/22/19.
//


/// A schema context stores information about a schema.
/// All schemas can have the contextual information in
/// this protocol.
public protocol JSONSchemaContext {
}

extension JSONSchema {
  /// The context that applies to all schemas.
  public struct CoreContext<Format: OpenAPIFormat>: JSONSchemaContext, Equatable {
    public let format: Format
    public let required: Bool // default true
    
    public init(
      format: Format = .unspecified,
      required: Bool = true
    ) {
      self.format = format
      self.required = required
    }
  }
}

extension JSONSchema {
  // not nested because Context is a generic type
  internal enum ContextCodingKeys: String, CodingKey {
    case type
    case format
  }
}

extension JSONSchema.CoreContext: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: JSONSchema.ContextCodingKeys.self)
    
    try container.encode(format.jsonType, forKey:   .type)
    
    if format != Format.unspecified {
      try container.encode(format, forKey: .format)
    }
  }
}

extension JSONSchema.CoreContext: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: JSONSchema.ContextCodingKeys.self)
    format = try container.decodeIfPresent(Format.self, forKey: .format) ?? .unspecified
    // defaults to `true` at decoding site.
    // It is the responsibility of decoders further upstream
    // to mark this as _not_ required if needed using
    // `.optionalContext()`.
    required = true
  }
}
