import OMPCore
//import SwiftGrammarMLX
import Testing

@testable import OMPMLX

@Suite("OMPMLX")
struct OMPMLXTests {
  let model = MLXLanguageModel(modelId: "vqstudio/Bielik-1.5B-v3.0-Instruct-MLX-4bit")
  
  @Test func basicResponse() async throws {
    let session = OMP.LanguageModelSession(model: model)
    let response = try await session.respond(to: .init("Say hello"))
    #expect(!response.content.isEmpty)
  }
}
