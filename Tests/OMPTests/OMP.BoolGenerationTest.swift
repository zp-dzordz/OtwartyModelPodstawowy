import Testing
@testable import OMP

@Test func testBoolGeneration() async throws {
  let instruction = "Jesteś pomocnym asystentem, ekspertem od języka polskiego?"
  let session = OMP.LanguageModelSession(instructions: instruction)
  let options = OMP.GenerationOptions(temperature: 0.0, maximumResponseTokens: 1024)
  let prompt = OMP.Prompt("Czy kolor biały znajduje się w godle państwa polskiego")
  let response = try await session.respond(to: prompt, generating: Bool.self, options: options)
  #expect(
    response.content == true
  )
  
}
