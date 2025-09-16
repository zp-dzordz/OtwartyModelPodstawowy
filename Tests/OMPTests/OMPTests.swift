import Testing
@testable import OMP

@MainActor
@Test func testBasic() async throws {
  let instruction = "Jesteś pomocnym asystentem, ekspertem od języka polskiego."
  
  let ompModel = OMP.Model()
  let llmModel = try await ompModel.load()
  
  let session = OMP.LanguageModelSession(model: llmModel, instructions: instruction)
  let options = OMP.GenerationOptions(
    temperature: 0.6,
    maximumResponseTokens: 2000
  )
  
  let prompts = [
    "Napisz w 3 zdaniach twoją definicję elokwencji literackiej"
  ]
  let response = try await session.respond(to: prompts[0], options: options)
  print(response)
  
//  print(response)
}


  
  
//  // Write your test here and use APIs like `#expect(...)` to check expected conditions.
//}
