extension OMP {
  /// The availability status for a specific language model.
  public enum Availability<UnavailableReason> {
      /// The model is ready for making requests.
      case available

      /// Indicates that the model is not ready for requests.
      case unavailable(UnavailableReason)
  }
}

extension OMP.Availability: Equatable where UnavailableReason: Equatable {}
extension OMP.Availability: Hashable where UnavailableReason: Hashable {}
extension OMP.Availability: Sendable where UnavailableReason: Sendable {}
