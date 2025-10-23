import Foundation
import Testing
@testable import OMP

enum Kind {
  case sightseeing
  case foodAndDining
  case shopping
  case hotelAndLodging
  
  var symbolName: String {
    switch self {
    case .sightseeing: "binoculars.fill"
    case .foodAndDining: "fork.knife"
    case .shopping: "bag.fill"
    case .hotelAndLodging: "bed.double.fill"
    }
  }
  
//  nonisolated static var ompGenerationSchema: OMP.GenerationSchema {
//    OMP.GenerationSchema(type: Self.self, anyOf: ["sightseeing", "foodAndDining", "shopping", "hotelAndLodging"])
//  }
  
  nonisolated var generatedContent: OMP.GeneratedContent {
    switch self {
    case .sightseeing:
      "sightseeing".ompGeneratedContent
    case .foodAndDining:
      "foodAndDining".ompGeneratedContent
    case .shopping:
      "shopping".ompGeneratedContent
    case .hotelAndLodging:
      "hotelAndLodging".ompGeneratedContent
    }
  }
}

//extension Kind: nonisolated OMP.Generable {
//  nonisolated init(_ content: OMP.GeneratedContent) throws {
//    let rawValue = try content.value(String.self)
//    switch rawValue {
//    case "sightseeing":
//      self = .sightseeing
//    case "foodAndDining":
//      self = .foodAndDining
//    case "shopping":
//      self = .shopping
//    case "hotelAndLodging":
//      self = .hotelAndLodging
//    default:
//      throw
//      OMP.LanguageModelSession.GenerationError.decodingFailure(OMP.LanguageModelSession.GenerationError.Context(debugDescription: "Unexpected value \"\(rawValue)\" for \(Self.self)"))
//    }
//  }
//}



struct GeneratbleTests {
  
}

