import RegexBuilder
import Testing
@testable import OMP

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
}

