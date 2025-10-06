import Foundation

extension OMP {
  @available(iOS 13.0, macOS 15.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public struct GenerationID : Sendable, Hashable {
    private let uuid = UUID()
    public init() {}
  }
}
