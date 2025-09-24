
import FoundationModels

@available(macOS 26.0, *)
@Generable
public enum MathNumber: Sendable, Equatable, Codable, Hashable {
  case natural(Int)         // ℕ
  case real(Double)          // ℝ
  // Error when uncommenting line below: @Guide can only be used with a stored property. (from macro 'Guide')
  //@Guide(description: "Ten przypadek dla liczb zespolonych")
  case complex(real: Double, imag: Double)  // ℂ
}

@available(macOS 26.0, *)
extension MathNumber {
  var isNatural: Bool {
    if case .natural = self { return true }
    return false
  }
  
  var asDouble: Double {
    switch self {
    case .natural(let n): return Double(n)
    case .real(let r): return r
    case .complex(let r, let i) where i == 0: return r
    default: fatalError("Cannot convert non-real complex to Double")
    }
  }
}

@available(macOS 26.0, *)
@Generable
struct RandomNumber {
  @Guide(description: "Losowy numer w jednej z trzech kategorii: liczba naturalna, liczba rzeczywista, liczba zespolona, najlepiej powiązany z jakimś konkretnym zastosowaniem, n.p liczta pi dla liczb rzeczywistych")
  var type: MathNumber
  @Guide(description: "Krótki opis (3 zdania) popularnego zasosowania wylosowanego numeru")
  var description: String
}

// Because Numbers struct is Generable FoundationModels will automatically convert it to text
// that the model can understand

@available(macOS 26.0, *)
@Generable
struct Numbers {
  @Guide(description: "tablica 3 losowych liczb w kolejno następujących kategoriach: liczba naturalna, liczba rzeczywista, liczba zespolona")
  @Guide(.count(3))
  var value: [RandomNumber]
}

import Observation

@available(macOS 26.0, *)
@MainActor
final public class RandomNumbersGenerator {
  private let session: LanguageModelSession
  private var numbers: Numbers?
  
  public init() {
    self.session = LanguageModelSession {
      "Twoim zadaniem jest stworzenie struktury zawierającej tablicę losowych liczb"
      "Tutaj przykład:"
      Numbers.example
    }
  }
  
  public func suggestNumbers() async throws {
    let response = try await session.respond(generating: Numbers.self) {
      "Stwórz strukturę zawierająca różne typy liczb."
    }
    self.numbers = response.content
  }
}

@available(macOS 26.0, *)
extension Numbers {
  public static let example = Numbers(
    value: [
      .init(
        type: .natural(2),
        description: "liczba ludzi potrzebnych do zawarcia małżeństwa."
      ),
      .init(
        type: .real(3.14),
        description: "Liczba pi - określa stosunek obwodu koła do jego średnicy."
      ),
      .init(
        type: .complex(
          real: 0,
          imag: 1
        ),
        description: "i - jednostka urojona liczby zespolonej."
      )
    ]
  )
}
