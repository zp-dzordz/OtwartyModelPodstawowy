import Foundation
import RegexBuilder
import Testing
@testable import OMPCore

struct GenerationGuideTests {
  
  @Test("constant() enforces exact match")
  func testConstant() async throws {
    let guide = GenerationGuide.constant("hello")
    
    #expect(guide.validate("hello"))
    #expect(!guide.validate("HELLO"))
    #expect(!guide.validate("hello "))
    #expect(!guide.validate("hi"))
  }
  
  @Test("anyOf() accepts only listed strings")
  func testAnyOf() async throws {
    let guide = GenerationGuide.anyOf(["red", "green", "blue"])
    
    #expect(guide.validate("red"))
    #expect(guide.validate("blue"))
    #expect(!guide.validate("yellow"))
    #expect(!guide.validate(""))
  }
  
  @Test("pattern() enforces regex matching")
  func testPatternSimple() async throws {
    let guide = GenerationGuide.pattern(/^hello$/)
    
    #expect(guide.validate("hello"))
    #expect(!guide.validate("hello there"))
    #expect(!guide.validate(" hi hello"))
  }
  
  @Test("pattern() supports complex regex")
  func testPatternEmail() async throws {
    let emailPattern = Regex {
      OneOrMore(.word)
      "@"
      OneOrMore(.word)
      "."
      OneOrMore(.word)
    }
    
    let guide = GenerationGuide.pattern(emailPattern)
    
    #expect(guide.validate("user@example.com"))
    #expect(guide.validate("a@b.c"))
    #expect(!guide.validate("invalid-email"))
    #expect(!guide.validate("user@"))
  }
  
  @Test("and() requires both conditions")
  func testAndComposition() async throws {
    let guide = GenerationGuide.pattern(/hello/)
      .and(.pattern(/world/))
    
    #expect(guide.validate("hello world"))
    #expect(!guide.validate("hello"))
    #expect(!guide.validate("world"))
  }
  
  
  @Test("or() allows either condition")
  func testOrComposition() async throws {
    let guide = GenerationGuide.constant("yes")
      .or(.constant("no"))
    
    #expect(guide.validate("yes"))
    #expect(guide.validate("no"))
    #expect(!guide.validate("maybe"))
  }
  
  @Test("not() inverts validation")
  func testNotComposition() async throws {
    let guide = GenerationGuide.constant("hello").not()
    
    #expect(!guide.validate("hello"))
    #expect(guide.validate("hi"))
  }
  
  @Test("complex combined composition")
  func testComplexComposition() async throws {
    let base = GenerationGuide.anyOf(["apple", "banana"])
    let regex = GenerationGuide.pattern(/fruit/)
    let combined = base.or(regex).and(.not(.constant("apple"))())
    
    #expect(combined.validate("banana"))
    #expect(combined.validate("fruit salad"))
    #expect(!combined.validate("apple"))   // filtered out by NOT
    #expect(!combined.validate("carrot"))
  }
  
  // MARK: - Int
  @Test("Int minimum() enforces lower bound inclusive")
  func testIntMinimum() async throws {
      let guide = GenerationGuide<Int>.minimum(10)
      #expect(guide.validate(10))
      #expect(guide.validate(11))
      #expect(!guide.validate(9))
  }

  @Test("Int maximum() enforces upper bound inclusive")
  func testIntMaximum() async throws {
      let guide = GenerationGuide<Int>.maximum(10)
      #expect(guide.validate(10))
      #expect(guide.validate(9))
      #expect(!guide.validate(11))
  }

  @Test("Int range() enforces inclusive range")
  func testIntRange() async throws {
      let guide = GenerationGuide<Int>.range(5...10)
      #expect(guide.validate(5))
      #expect(guide.validate(8))
      #expect(guide.validate(10))
      #expect(!guide.validate(4))
      #expect(!guide.validate(11))
  }

  // MARK: - Float
  @Test("Float minimum() and maximum() are inclusive")
  func testFloatMinMax() async throws {
      let minGuide = GenerationGuide<Float>.minimum(1.5)
      let maxGuide = GenerationGuide<Float>.maximum(3.5)
      #expect(minGuide.validate(1.5))
      #expect(minGuide.validate(2.0))
      #expect(!minGuide.validate(1.4))
      #expect(maxGuide.validate(3.5))
      #expect(maxGuide.validate(2.5))
      #expect(!maxGuide.validate(3.6))
  }

  @Test("Float range() works correctly with boundaries")
  func testFloatRange() async throws {
      let guide = GenerationGuide<Float>.range(0.0...1.0)
      #expect(guide.validate(0.0))
      #expect(guide.validate(0.5))
      #expect(guide.validate(1.0))
      #expect(!guide.validate(-0.1))
      #expect(!guide.validate(1.1))
  }
  
  // MARK: - Decimal
  @Test("Decimal minimum() / maximum() / range() behave correctly")
  func testDecimalBoundaries() async throws {
      let minGuide = GenerationGuide<Decimal>.minimum(Decimal(2.5))
      let maxGuide = GenerationGuide<Decimal>.maximum(Decimal(7.5))
      let rangeGuide = GenerationGuide<Decimal>.range(Decimal(2.5)...Decimal(7.5))

      #expect(minGuide.validate(Decimal(2.5)))
      #expect(!minGuide.validate(Decimal(2.4)))

      #expect(maxGuide.validate(Decimal(7.5)))
      #expect(!maxGuide.validate(Decimal(8)))

      #expect(rangeGuide.validate(Decimal(5)))
      #expect(!rangeGuide.validate(Decimal(2)))
      #expect(!rangeGuide.validate(Decimal(8)))
  }
  
  // MARK: - Double
  @Test("Double minimum() / maximum() / range() inclusive behavior")
  func testDoubleBoundaries() async throws {
      let minGuide = GenerationGuide<Double>.minimum(0.5)
      let maxGuide = GenerationGuide<Double>.maximum(1.5)
      let rangeGuide = GenerationGuide<Double>.range(0.5...1.5)

      #expect(minGuide.validate(0.5))
      #expect(!minGuide.validate(0.49))

      #expect(maxGuide.validate(1.5))
      #expect(!maxGuide.validate(1.51))

      #expect(rangeGuide.validate(1.0))
      #expect(!rangeGuide.validate(2.0))
  }
  
  // MARK: - Array count & element validation
  @Test("Array minimumCount() enforces inclusive lower bound")
  func testArrayMinimumCount() async throws {
      let guide = GenerationGuide<[Int]>.minimumCount(2)
      #expect(guide.validate([1, 2]))
      #expect(guide.validate([1, 2, 3]))
      #expect(!guide.validate([1]))
      #expect(!guide.validate([]))
  }

  @Test("Array maximumCount() enforces inclusive upper bound")
  func testArrayMaximumCount() async throws {
      let guide = GenerationGuide<[Int]>.maximumCount(3)
      #expect(guide.validate([1]))
      #expect(guide.validate([1, 2, 3]))
      #expect(!guide.validate([1, 2, 3, 4]))
  }

  @Test("Array count(range) enforces inclusive range")
  func testArrayCountRange() async throws {
      let guide = GenerationGuide<[Int]>.count(2...4)
      #expect(guide.validate([1, 2]))
      #expect(guide.validate([1, 2, 3, 4]))
      #expect(!guide.validate([1]))
      #expect(!guide.validate([1, 2, 3, 4, 5]))
  }

  @Test("Array count(count) enforces exact element count")
  func testArrayExactCount() async throws {
      let guide = GenerationGuide<[Int]>.count(3)
      #expect(guide.validate([1, 2, 3]))
      #expect(!guide.validate([1, 2]))
      #expect(!guide.validate([1, 2, 3, 4]))
  }

  @Test("Array element() enforces element-level constraints")
  func testArrayElementGuide() async throws {
      let numberArrayGuide = GenerationGuide<[String]>.element(
          GenerationGuide.pattern(/^[0-9]*$/)
      )
      #expect(numberArrayGuide.validate(["1", "2", "999"]))
      #expect(!numberArrayGuide.validate(["1", "A"]))
  }

  @Test("Array element() combining numeric guide")
  func testArrayElementNumericGuide() async throws {
      let positiveGuide = GenerationGuide<Int>.minimum(0)
      let arrayGuide = GenerationGuide<[Int]>.element(positiveGuide)

      #expect(arrayGuide.validate([0, 1, 2, 10]))
      #expect(!arrayGuide.validate([-1, 0, 1]))
  }


}

