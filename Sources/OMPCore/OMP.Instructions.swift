import Foundation

extension OMP {
  /// Instructions define the model's intended behavior on prompts.
  ///
  /// Instructions are typically provided by you to define the role and behavior of the model. In the code below,
  /// the instructions specify that the model replies with topics rather than, for example, a recipe:
  ///
  /// ```swift
  /// let instructions = """
  ///     Suggest related topics. Keep them concise (three to seven words) and \
  ///     make sure they build naturally from the person's topic.
  ///     """
  public struct Instructions {
    init(_internal: String) {
      self._internal = _internal
    }
    public init(_ content: some InstructionsRepresentable) {
      if let existing = content as? Instructions {
        self = existing
      } else {
        self = content.ompInstructionsRepresentation
      }
    }
    var _internal: String = ""
  }
}

extension OMP.Instructions: OMP.InstructionsRepresentable {
  /// An instance that represents the instructions.
  public var ompInstructionsRepresentation: OMP.Instructions { self }
}

extension OMP.Instructions {
  public init(@OMP.InstructionsBuilder _ content: () throws -> OMP.Instructions) rethrows {
    let built = try content()
    self = built
  }
}

extension OMP {
  @resultBuilder public struct InstructionsBuilder {
    public static func buildBlock<each I>(_ components: repeat each I) -> Instructions where repeat each I : InstructionsRepresentable {
      var parts: [String] = []
      var representables: [InstructionsRepresentable] = []
      for part in repeat each components {
        if let instruction = part as? Instructions {
          parts.append(instruction._internal)
        }
        representables.append(part)
      }
      if parts.count > .zero {
        return Instructions(_internal: parts.joined(separator: "\n"))
      }
      let mirror = Mirror(reflecting: representables)
      let strings = mirror.children.map {
        child in
        if let s = child.value as? String { return s }
        return String(describing: child.value)
      }
      return Instructions(_internal: strings.joined(separator: "\n"))
    }
    
    public static func buildArray(_ instructions: [some InstructionsRepresentable]) -> Instructions {
      let joined = instructions
        .map { $0.ompInstructionsRepresentation._internal }
        .joined(separator: "\n")
      return Instructions(_internal: joined)
    }
    
    public static func buildEither(first component: some InstructionsRepresentable) -> Instructions {
      component.ompInstructionsRepresentation
    }
    
    public static func buildEither(second component: some InstructionsRepresentable) -> Instructions {
      component.ompInstructionsRepresentation
    }
    
    public static func buildOptional(_ instructions: Instructions?) -> Instructions {
      instructions ?? Instructions(_internal: "")
    }
    
    public static func buildLimitedAvailability(_ instructions: some InstructionsRepresentable) -> Instructions {
      instructions.ompInstructionsRepresentation
    }
    
    public static func buildExpression<I>(_ expression: I) -> I where I : InstructionsRepresentable {
      expression
    }
    
    public static func buildExpression(_ expression: Instructions) -> Instructions {
      expression
    }
  }
}

extension OMP {
  /// Conforming types represent instructions.
  public protocol InstructionsRepresentable {
    /// An instance that represents the instructions.
    @InstructionsBuilder var ompInstructionsRepresentation: Instructions { get }
  }
  /// Instructions define the model's intended behavior on prompts.
}

extension String: OMP.InstructionsRepresentable {
  public var ompInstructionsRepresentation: OMP.Instructions {
    // Use the *base* initializer that doesn't recurse
    OMP.Instructions(_internal: self)
  }
}

extension Array: OMP.InstructionsRepresentable where Element: OMP.InstructionsRepresentable {
  public var ompInstructionsRepresentation: OMP.Instructions {
    self.map { $0.ompInstructionsRepresentation._internal }.joined(separator: "\n")
  }
}

