import Observation
import Testing
@testable import OMP

@Test func testString() async throws {
  let content = OMP.GeneratedContent("Hello")
  print(content.jsonString)
}
