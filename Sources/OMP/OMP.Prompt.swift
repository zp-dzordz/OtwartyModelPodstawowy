extension OMP {
  
  /// A protocol that represents a prompt.
  @available(iOS 13.0, macOS 15.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public protocol PromptRepresentable { }
}

@available(iOS 13.0, macOS 15.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension String: OMP.PromptRepresentable {}

