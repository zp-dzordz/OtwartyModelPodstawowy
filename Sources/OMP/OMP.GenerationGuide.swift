import Foundation
import RegexBuilder

public struct GenerationGuide<Value> {
  // Internal validation closure
  let validator: (Value) -> Bool
  
  // Generic initializer
  internal init(validator: @escaping (Value) -> Bool) {
    self.validator = validator
  }
  
  /// Checks whether a given value satisfies this guide.
  public func validate(_ value: Value) -> Bool {
    validator(value)
  }
}

// MARK: - Logical Composition
extension GenerationGuide {
  /// Returns a new guide that requires *both * guides to be satisfied
  public func and(_ other: GenerationGuide<Value>) -> GenerationGuide<Value> {
    GenerationGuide { value in      
      return self.validator(value) && other.validator(value)
    }
  }
  /// Returns a new guide that requires *either* guide to be satisfied.
  public func or(_ other: GenerationGuide<Value>) -> GenerationGuide<Value> {
      GenerationGuide { value in
          self.validator(value) || other.validator(value)
      }
  }
  /// Returns a new guide that requires *this guide not to be satisfied*.
  public func not() -> GenerationGuide<Value> {
      GenerationGuide { value in
          !self.validator(value)
      }
  }
}

extension GenerationGuide where Value == String {
  /// Enforces that the string be precisely the given value.
  public static func constant(_ value: String) -> GenerationGuide<String> {
    GenerationGuide { candidate in
      candidate == value
    }
  }
  /// Enforces that the string be one of the provided values.
  public static func anyOf(_ values: [String]) -> GenerationGuide<String> {
    GenerationGuide { candidate in
      values.contains(candidate)
    }
  }
  /// Enforces that the string follows the pattern.
  /// NOTE: This uses `firstMatch(of:)`, i.e. *substring* matching by default.
  /// If you want the whole-string to match, pass an anchored regex like `^...$`.
  public static func pattern<Output>(_ regex: Regex<Output>) -> GenerationGuide<String> {
    GenerationGuide { candidate in
      candidate.firstMatch(of: regex) != nil
    }
  }
}
