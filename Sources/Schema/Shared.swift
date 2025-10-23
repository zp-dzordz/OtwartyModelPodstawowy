//
//  Shared.swift
//
//
//  Created by Mathew Polzin on 12/24/22.
//

/// A Core namespace for OpenAPI types that are shared by multiple OpenAPI standard versions.
public enum Shared {}

extension Shared {
  /// The allowed "format" properties for `.boolean` schemas.
  public enum BooleanFormat: RawRepresentable, Equatable {
    case generic
    case other(String)
    
    public var rawValue: String {
      switch self {
      case .generic: return ""
      case .other(let other):
        return other
      }
    }
    
    public init(rawValue: String) {
      switch rawValue {
      case "": self = .generic
      default: self = .other(rawValue)
      }
    }
    
    public typealias SwiftType = Bool
    
    public static var unspecified: BooleanFormat {
      return .generic
    }
  }
}

