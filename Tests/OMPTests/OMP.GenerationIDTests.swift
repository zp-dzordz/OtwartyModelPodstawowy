import Testing
@testable import OMP

@Test func testGenerationID() async throws {
  let a = OMP.GenerationID()
  let b = a
  let c = OMP.GenerationID()
  
  #expect(a == b)
  #expect(a != c)
  
  
  var set: Set<OMP.GenerationID> = []
  set.insert(a)
  #expect(set.contains(b))
  #expect(set.contains(c) == false)
}
