//
//  TypesAndFormats.swift
//
//
//  Created by Mathew Polzin on 6/22/19.
//

// MARK: Types
/// An OpenAPI type with an associated value representing its Swift type.
///
/// For example, `JSONTypeFormat.BooleanFormat` is associated with
/// the `Bool` Swift type.
public protocol SwiftTyped {
    associatedtype SwiftType: Codable, Equatable
}


/// The raw types supported by JSON Schema.
///
/// These are the OpenAPI [data types](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#data-types)
/// and additionally the `object` and `array`
/// "compound" data types.
/// - boolean
/// - object
/// - array
/// - number
/// - integer
/// - string
public enum JSONType: String, Codable {
    case boolean = "boolean"
    case object = "object"
    case array = "array"
    case number = "number"
    case integer = "integer"
    case string = "string"

    public var group: String {
        switch self {
        case .boolean: return "boolean"
        case .object: return "object"
        case .array: return "array"
        case .number, .integer: return "number/integer"
        case .string: return "string"
        }
    }
}

public enum JSONTypeFormat: Equatable {
  case boolean(BooleanFormat)
  
  public var jsonType: JSONType {
    switch self {
    case .boolean:
      return .boolean
    }
  }
  
  public var swiftType: Any.Type {
    switch self {
    case .boolean(let format):
      return type(of: format).SwiftType.self
    }
  }
}



// MARK: Formats
/// OpenAPI formats represent the valid formats a
/// raw type can take on to better specify its allowed
/// values and intended semantics.
///
/// For example, a `string` might have the `date-time` format, indicating
/// it is representative of a date/time and also indicating its format
/// adheres to the [RFC3339](https://xml2rfc.ietf.org/public/rfc/html/rfc3339.html#anchor14)
/// specification for a "date-time."
///
/// See "formats" under the OpenAPI [data type](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#data-types)
/// documentation.
public protocol OpenAPIFormat: SwiftTyped, Codable, Equatable, RawRepresentable, Validatable where RawValue == String {
    static var unspecified: Self { get }

    var jsonType: JSONType { get }
}

/// The allowed "format" properties for `.boolean` schemas.
extension JSONTypeFormat.BooleanFormat: OpenAPIFormat {
    public var jsonType: JSONType {
        return .boolean
    }
}

public extension JSONTypeFormat {
  typealias BooleanFormat = Shared.BooleanFormat
}
