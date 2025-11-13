import Foundation
import Schema

public extension SwiftGrammar {
  static func schema(_ schema: JSONSchema = .boolean(.init()), indent: Int? = nil) throws -> SwiftGrammar {
    let data = try JSONEncoder.sorted.encode(schema)
    let string = String(decoding: data, as: UTF8.self)
    return .schema(string, indent: indent)
  }
}
