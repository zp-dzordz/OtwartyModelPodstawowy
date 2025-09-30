import Testing
@testable import OMP

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
  let response = try await session.respond(to: prompts[0], options: options)
  #expect(
    response.content == """
    <s>  Elokwencja literacka to umiejętność wyrażania myśli w sposób piękny, literacki i przekonujący. To zdolność do posługiwania się językiem w sposób wyrafinowany i elegancki, który zachwyca czytelnika i pozostawia na nim trwałe wrażenie. To także umiejętność tworzenia tekstów, które są pełne głębokich treści i emocji, które poruszają serca i umysły.
    """)
}
