import Testing
@testable import Schema

struct JSONSchemaBasicTest {
  @Test("json type format")
  func test_jsonTypeFormat() async throws {
    let boolean = JSONSchema(schema: .boolean(.init(format: .unspecified, required: true)))
    
    // JSONTypeFormat
    #expect(boolean.jsonTypeFormat == .boolean(.unspecified))
    
    // JSONType
    #expect(boolean.jsonTypeFormat?.jsonType == .boolean)
    
    #expect(boolean.jsonType == .boolean)
    
    // Format String
    #expect(boolean.formatString == "")
    
    // SwiftType
    #expect(boolean.jsonTypeFormat?.swiftType == Bool.self)
  }
  
  @Test
  func encodeBoolean() {
    let requiredBoolean = JSONSchema.boolean(.init(format: .unspecified, required: true))
    
    testAllSharedSimpleContextEncoding(
      typeName: "boolean",
      requiredEntity: requiredBoolean
    )
    
  }
    
  @Test
  func decodeBoolean() throws {
    let booleanData = #"{"type": "boolean"}"#.data(using: .utf8)!
    
    let boolean = try orderUnstableDecode(JSONSchema.self, from: booleanData)
    #expect(boolean == JSONSchema.boolean(.init(format: .generic)))
  }
}

private func testEncodingPropertyLines<T: Encodable>(
  entity: T,
  propertyLines: [String]
) {
  var expectedString = "{\n"
  for line in propertyLines {
    expectedString += "  " + line + "\n"
  }
  expectedString += "}"
    
  assertJSONEquivalent(try? orderUnstableTestStringFromEncoding(of: entity), expectedString)
}

private func testAllSharedSimpleContextEncoding<T: Encodable>(
  typeName: String,
  requiredEntity: T
) {
  testEncodingPropertyLines(
    entity: requiredEntity,
    propertyLines: ["\"type\" : \"\(typeName)\""]
  )
}
