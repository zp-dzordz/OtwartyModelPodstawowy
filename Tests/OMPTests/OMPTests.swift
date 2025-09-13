import Testing
@testable import OMP

@Test func testBasic() async throws {
  let instruction = "You are a helpful assistant"
  
  let session = OMP.LanguageModelSession(instructions: instruction)
  let options = OMP.GenerationOptions(
    temperature: 0.0,
    maximumResponseTokens: 2000
  )
  
  let prompts = [
    "Tell me a joke"
  ]
  
  let response = try await session.respond(to: prompts[0], options: options)
  
  print(response)
}


  
  
//  // Write your test here and use APIs like `#expect(...)` to check expected conditions.
//}
