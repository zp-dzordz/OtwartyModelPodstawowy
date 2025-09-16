extension OMP {
  @available(iOS 13.0, macOS 14.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public struct GenerationOptions: Sendable, Equatable {
    public var temperature: Double?
    public var maximumResponseTokens: Int?
    /// update the display every N tokens -- 4 looks like it updates continuously
    /// and is low overhead.  observed ~15% reduction in tokens/s when updating
    /// on every token
    public let displayEveryNTokens = 4
    
    public init(temperature: Double? = nil, maximumResponseTokens: Int? = nil) {
      self.temperature = temperature
      self.maximumResponseTokens = maximumResponseTokens
    }
  }
}
