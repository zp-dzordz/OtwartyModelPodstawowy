import Foundation
import Testing

fileprivate let foundationTestEncoder = { () -> JSONEncoder in
    let encoder = JSONEncoder()
    if #available(macOS 10.13, *) {
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .useDefaultKeys
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }
    #if os(Linux)
    encoder.dateEncodingStrategy = .iso8601
    encoder.keyEncodingStrategy = .useDefaultKeys
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    #endif
    return encoder
}()

func orderUnstableEncode<T: Encodable>(_ value: T) throws -> Data {
    return try foundationTestEncoder.encode(value)
}

func orderUnstableTestStringFromEncoding<T: Encodable>(of entity: T) throws -> String? {
    return String(data: try orderUnstableEncode(entity), encoding: .utf8)
}

fileprivate let foundationTestDecoder = { () -> JSONDecoder in
  let decoder = JSONDecoder()
  if #available(macOS 10.12, *) {
      decoder.dateDecodingStrategy = .iso8601
      decoder.keyDecodingStrategy = .useDefaultKeys
  }
  #if os(Linux)
  decoder.dateDecodingStrategy = .iso8601
  decoder.keyDecodingStrategy = .useDefaultKeys
  #endif
  return decoder
}()

func orderUnstableDecode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    return try foundationTestDecoder.decode(T.self, from: data)
}

func assertJSONEquivalent(_ str1: String?, _ str2: String?) {
  // when testing on Linux, pretty printing has slightly different
  // meaning so the tests pass on OS X as written but need whitespace
  // stripped to pass on Linux
  #if os(Linux)
  var str1 = str1
  var str2 = str2
  
  str1?.removeAll { $0.isWhitespace }
  str2?.removeAll { $0.isWhitespace }
  #endif
  #expect(str1 == str2)
}

