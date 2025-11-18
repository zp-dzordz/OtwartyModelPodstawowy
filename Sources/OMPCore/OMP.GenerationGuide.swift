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

extension GenerationGuide where Value == Int {
    public static func minimum(_ value: Int) -> GenerationGuide<Int> {
        GenerationGuide { candidate in candidate >= value }
    }

    public static func maximum(_ value: Int) -> GenerationGuide<Int> {
        GenerationGuide { candidate in candidate <= value }
    }

    public static func range(_ range: ClosedRange<Int>) -> GenerationGuide<Int> {
        GenerationGuide { candidate in range.contains(candidate) }
    }
}

// MARK: - Float constraints
extension GenerationGuide where Value == Float {
    public static func minimum(_ value: Float) -> GenerationGuide<Float> {
        GenerationGuide { candidate in candidate >= value }
    }

    public static func maximum(_ value: Float) -> GenerationGuide<Float> {
        GenerationGuide { candidate in candidate <= value }
    }

    public static func range(_ range: ClosedRange<Float>) -> GenerationGuide<Float> {
        GenerationGuide { candidate in range.contains(candidate) }
    }
}

// MARK: - Decimal constraints
extension GenerationGuide where Value == Decimal {
    public static func minimum(_ value: Decimal) -> GenerationGuide<Decimal> {
        GenerationGuide { candidate in candidate >= value }
    }

    public static func maximum(_ value: Decimal) -> GenerationGuide<Decimal> {
        GenerationGuide { candidate in candidate <= value }
    }

    public static func range(_ range: ClosedRange<Decimal>) -> GenerationGuide<Decimal> {
        GenerationGuide { candidate in range.contains(candidate) }
    }
}

// MARK: - Double constraints
extension GenerationGuide where Value == Double {
    public static func minimum(_ value: Double) -> GenerationGuide<Double> {
        GenerationGuide { candidate in candidate >= value }
    }

    public static func maximum(_ value: Double) -> GenerationGuide<Double> {
        GenerationGuide { candidate in candidate <= value }
    }

    public static func range(_ range: ClosedRange<Double>) -> GenerationGuide<Double> {
        GenerationGuide { candidate in range.contains(candidate) }
    }
}

// MARK: - Array constraints
extension GenerationGuide {

    public static func minimumCount<Element>(_ count: Int) -> GenerationGuide<[Element]> where Value == [Element] {
        GenerationGuide { candidate in candidate.count >= count }
    }

    public static func maximumCount<Element>(_ count: Int) -> GenerationGuide<[Element]> where Value == [Element] {
        GenerationGuide { candidate in candidate.count <= count }
    }

    public static func count<Element>(_ range: ClosedRange<Int>) -> GenerationGuide<[Element]> where Value == [Element] {
        GenerationGuide { candidate in range.contains(candidate.count) }
    }

    public static func count<Element>(_ count: Int) -> GenerationGuide<[Element]> where Value == [Element] {
        GenerationGuide { candidate in candidate.count == count }
    }

    public static func element<Element>(_ guide: GenerationGuide<Element>) -> GenerationGuide<[Element]> where Value == [Element] {
        GenerationGuide { candidate in candidate.allSatisfy { guide.validate($0) } }
    }
}

// MARK: - Array<Never> constraints (macro expansion placeholders)
extension GenerationGuide where Value == [Never] {

    public static func minimumCount(_ count: Int) -> GenerationGuide<Value> {
        GenerationGuide { _ in true }
    }

    public static func maximumCount(_ count: Int) -> GenerationGuide<Value> {
        GenerationGuide { _ in true }
    }

    public static func count(_ range: ClosedRange<Int>) -> GenerationGuide<Value> {
        GenerationGuide { _ in true }
    }

    public static func count(_ count: Int) -> GenerationGuide<Value> {
        GenerationGuide { _ in true }
    }
}
