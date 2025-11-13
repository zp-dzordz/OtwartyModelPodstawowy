import Foundation
import Schema

extension JSONEncoder {
  static let `default` = JSONEncoder()
  
  static let sorted: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
    return encoder
  }()
}


