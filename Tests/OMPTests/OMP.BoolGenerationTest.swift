import SwiftGrammar
import Schema
import Testing
@testable import OMPCore


@Test func testBoolGeneration() async throws {
  let schema = try! SwiftGrammar.schema(.boolean(.init()))
  guard case .schema(let jsonSchema, let indent) = schema else {
    return
  }
  let instruction = "Jesteś pomocnym asystentem, ekspertem od języka polskiego. Odpowiadaj używająć JSONSchema : \(jsonSchema)"
  let session = OMP.LanguageModelSession(instructions: instruction)
  let options = OMP.GenerationOptions(temperature: 0.0, maximumResponseTokens: 1024)
  let prompt = OMP.Prompt("Czy kolor biały znajduje się w godle państwa polskiego?")
  let response = try await session.respond(to: prompt, generating: Bool.self, options: options)
  #expect(
    response.content == true
  )
  
}
