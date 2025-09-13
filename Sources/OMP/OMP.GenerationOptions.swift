extension OMP {
  @available(iOS 13.0, macOS 14.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public struct GenerationOptions: Sendable, Equatable {
    public var temperature: Double?
    public var maximumResponseTokens: Int?
    
    public init(temperature: Double? = nil, maximumResponseTokens: Int? = nil) {
      self.temperature = temperature
      self.maximumResponseTokens = maximumResponseTokens
    }
  }
}
