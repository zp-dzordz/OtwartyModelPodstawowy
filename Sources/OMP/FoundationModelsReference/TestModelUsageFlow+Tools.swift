//
//  TestModelUsageFlow+Tools.swift
//  OtwartyModelPodstawowy
//
//  Created by Grzegorz Kiel on 30/09/2025.
//

import CoreLocation
import MapKit

struct Landmark: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var continent: String
    var description: String
    var shortDescription: String
    var latitude: Double
    var longitude: Double
    var span: Double
    var placeID: String?
    
    var backgroundImageName: String {
        return "\(id)"
    }
    
    var thumbnailImageName: String {
        return "\(id)-thumb"
    }
    
    var locationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude)
    }
    
    var coordinateRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: locationCoordinate,
            span: .init(latitudeDelta: span, longitudeDelta: span)
        )
    }
}

@available(macOS 26.0, *)
@Generable
enum Category: String, CaseIterable {
  case hotel
  case restaurant
}

import FoundationModels
import Observation
import Playgrounds

@available(macOS 26.0, *)
@Observable
final class FindPointsOfInterestTool: Tool {
  let name = "findPointsOfInterest"
  let description = "Finds points of interest for a landmark."
  
  let landmark: Landmark
  init(landmark: Landmark) {
    self.landmark = landmark
  }
  
  @Generable
  struct Arguments {
    @Guide(description: "This is the type of business to look up for.")
    let pointOfInterest: Category
  }
  
  func call(arguments: Arguments) async throws -> String {
    let results = await getSuggestions(category: arguments.pointOfInterest, landmark: landmark.name)
    return """
    There are these \(arguments.pointOfInterest) in \(landmark.name):
    \(results.joined(separator: ", "))
    """
  }
}

@available(macOS 26.0, *)
func getSuggestions(category: Category, landmark: String) async -> [String] {
  switch category {
  case .hotel: ["Hotel 1", "Hotel 2", "Hotel 3"]
  case .restaurant: ["Restaurant 1", "Restaurant 2", "Restaurant 3"]
  }
}

@available(macOS 26.0, *)
@Observable
@MainActor
final class ItineraryGenerator {
  var error: Error?
  let landmark: Landmark
  
  private var session: LanguageModelSession
  
  private(set) var itinerary: Itinerary.PartiallyGenerated?
  
  init(landmark: Landmark) {
    self.landmark = landmark
    let pointOfInterestTool = FindPointsOfInterestTool(landmark: landmark)
    let instructions = Instructions {
      "Your job is to create an itinerary for the user."
      "For each day, you must suggest one hotel and one restaurant."
      "Always use the 'findPointsOfInterest' tool to find hotels and resturants in \(landmark.name)"
    }
    self.session = LanguageModelSession(tools: [pointOfInterestTool], instructions: instructions)
  }
  
  func generateItinerary(dayCount: Int = 3) async {
    // MARK: - [CODE-ALONG] Chapter 6.2.1: Update to exclude schema from prompt
    do {
      let prompt = Prompt {
        "Generate a \(dayCount)-day itinerary to \(landmark.name)."
        "Give it a fun title and description"
        "Here is an example of the desired format, but don't copy its content:"
        Itinerary.exampleTripToJapan
      }
      // In final implementation pick one out of those two
      // One-shot API
//      let response = try await session.respond(
//        to: prompt,
//        generating: Itinerary.self,
//        options: GenerationOptions(sampling: .greedy)
//      )
      // Stream API
      let stream = session.streamResponse(
        to: prompt,
        generating: Itinerary.self,
        includeSchemaInPrompt: false
      )
      for try await partialResponse in stream {
        self.itinerary = partialResponse.content
      }
    }
    catch {
      self.error = error
    }
  }
  
  func prewarmModel() {
    session.prewarm()
  }
}

