import Observation
import Testing
@testable import OMP

extension OMP {
  @Observable
  @MainActor
  final class ItineraryGenerator {
    var error: Error?
    let landmark: Landmark
    
//    private var session: LanguageModelSession
    
    init(landmark: Landmark) {
      self.landmark = landmark
      let pointOfInterestTool = FindPointOfInterestTool(landmark: landmark)
      let instruction = """
      Your job is to create an itinerary for the user.
      For each day, you must suggest one hotel and one restaurant.
      Always use the 'findPointOfInterest' tool to find hotels and restaurants in \(landmark.name)
      """
      
    }
  }
}

@MainActor
@Test func testTool() async throws {
  
}
