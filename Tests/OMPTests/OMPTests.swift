import Testing
@testable import OMPCore

// TODO: Detect the locale and load appropriate model
// TODO: Handle model availability
// TODO: tool calling
// TODO: @Generable macro support
// TODO: @Guide macro support
// TODO: Implement @PromptBuilder
// TODO: Implement @InstructionBuilder
// TODO: Streaming responses


@MainActor
@Test func testBasic() async throws {
  let instruction = "Jesteś pomocnym asystentem, ekspertem od języka polskiego i matematyki."
  let session = OMP.LanguageModelSession(instructions: instruction)
  let options = OMP.GenerationOptions(temperature: 0.0, maximumResponseTokens: 1024)
  let prompts = [
    "Napisz w 3 zdaniach twoją definicję elokwencji literackiej"
  ]
  do {
    let response = try await session.respond(to: prompts[0], options: options)
    #expect(
      response.content == """
      Elokwencja literacka to umiejętność wyrażania myśli i uczuć w sposób elegancki, precyzyjny i przekonujący, często z użyciem metafor, porównań i innych środków stylistycznych, które wzbogacają przekaz i ułatwiają zrozumienie.
      """)
  } catch {
    print("Error: \(error.localizedDescription)")
  }
}

