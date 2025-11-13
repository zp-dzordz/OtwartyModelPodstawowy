import MLX
import Schema
@testable import SwiftGrammar
import Testing

@Test func testBooleanJSONSchemaGrammarMatcher() async throws {
  let vocab = ["<eos>", "t", "r", "u", "e", "}", " ", "\""]
  
  let grammar = try SwiftGrammar.schema(.boolean(.init()))
  let grammarMatcher = try XGrammar(vocab: vocab, stopTokenIds: [0], grammar: grammar)
  let advances: [Int] =  #"true"#.map(String.init).compactMap({ vocab.firstIndex(of: $0) }) + [0]
  let expectations: [[Int]] = [
    [0, 1, 0, 0, 0, 0, 0, 0], // "t"
    [0, 0, 1, 0, 0, 0, 0, 0], // "r"
    [0, 0, 0, 1, 0, 0, 0, 0], // "u"
    [0, 0, 0, 0, 1, 0, 0, 0], // "e"
    [1, 0, 0, 0, 0, 0, 0, 0] // "<eos>"
  ]
  
  for (expectation, advance) in zip(expectations, advances) {
    let mask = grammarMatcher.nextTokenMask()
    let allowed = mask.exp().asArray(Int.self)
    #expect(allowed == expectation)
    grammarMatcher.advance(token: MLXArray(advance))
  }
}

