import Testing
@testable import SwiftGrammar

@Test
func testEmptyJSONSchemaGrammar() async throws {
  #expect(
    performing: {
      let grammar = SwiftGrammar.schema("")
      let _ = try XGrammar(vocab: ["a", "b", "c"], grammar: grammar)
    },
    throws: { error in
    switch error {
    case XCGrammarError.emptyGrammar:
      return true
    default:
      return false
    }
  }
  )
}

@Test func testIncorrectJSONSchemaGrammar() async throws {
  #expect(performing: {
    let grammar = SwiftGrammar.schema(#"{"type": "foo"}"#)
    let _ = try XGrammar(vocab: ["a", "b", "c"], grammar: grammar)
  }, throws: { error in
    switch error {
    case XCGrammarError.invalidGrammar(let message):
      return message.contains("Unsupported type \"foo\"")
    default:
      return false
    }
  })
}
