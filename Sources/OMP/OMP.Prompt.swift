extension OMP {
  /// A prompt from a person to the model.
  ///
  /// Prompts can contain content written by you, an outside source, or input directly from people using
  /// your app. You can initialize a `Prompt` from a string literal:
  ///
  /// ```swift
  /// let prompt = Prompt("What are miniature schnauzers known for?")
  /// ```
  ///
  /// Use ``PromptBuilder`` to dynamically control the prompt's content based on your app's state. The
  /// code below shows if the Boolean is `true`, the prompt includes a second line of text:
  ///
  /// ```swift
  /// let responseShouldRhyme = true
  /// let prompt = Prompt {
  ///     "Answer the following question from the user: \(userInput)"
  ///     if responseShouldRhyme {
  ///         "Your response MUST rhyme!"
  ///     }
  /// }
  /// ```
  ///
  /// If your prompt includes input from people, consider wrapping the input in a string template with your
  /// own prompt to better steer the model's response. For more information on handling inputs in your
  /// prompts, see <doc:improving-safety-from-generative-model-output>.
  public struct Prompt : Sendable {
    init(_internal: String) {
      self._internal = _internal
    }
      /// Creates an instance with the content you specify.
    public init(_ content: some PromptRepresentable) {
      if let existing = content as? Prompt {
        self = existing
      } else {
        self = content.ompPromptRepresentation
      }
    }
    var _internal: String = ""
  }
}

extension OMP.Prompt: OMP.PromptRepresentable {
  /// An instance that representes the prompt.
  public var ompPromptRepresentation: OMP.Prompt {
    self
  }
}

extension OMP.Prompt {
  public init(@OMP.PromptBuilder _ content: () throws -> OMP.Prompt) rethrows {
    let built = try content()
    self = built
  }
}

extension OMP {
  @resultBuilder public struct PromptBuilder {
    /// Creates a builder with the a block.
    public static func buildBlock<each P>(_ components: repeat each P) -> Prompt where repeat each P : PromptRepresentable {
      var parts: [String] = []
      var representables: [PromptRepresentable] = []
      for part in repeat each components {
        if let instruction = part as? Prompt {
          parts.append(instruction._internal)
        }
        representables.append(part)
      }
      if parts.count > .zero {
        return Prompt(_internal: parts.joined(separator: "\n"))
      }
      let mirror = Mirror(reflecting: representables)
      let strings = mirror.children.map {
        child in
        if let s = child.value as? String { return s }
        return String(describing: child.value)
      }
      return Prompt(_internal: strings.joined(separator: "\n"))
    }
    
    public static func buildArray(_ prompts: [some PromptRepresentable]) -> Prompt {
      let joined = prompts
        .map { $0.ompPromptRepresentation._internal }
        .joined(separator: "\n")
      return Prompt(_internal: joined)
    }
    
    public static func buildEither(first component: some PromptRepresentable) -> Prompt {
      component.ompPromptRepresentation
    }
    
    public static func buildEither(second component: some PromptRepresentable) -> Prompt {
      component.ompPromptRepresentation
    }
    
    public static func buildOptional(_ prompt: Prompt?) -> Prompt {
      prompt ?? Prompt(_internal: "")
    }
    
    public static func buildExpression<I>(_ expression: I) -> I where I : PromptRepresentable {
      expression
    }
    
    public static func buildExpression(_ expression: Prompt) -> Prompt {
      expression
    }
  }
}

extension OMP {
  public protocol PromptRepresentable {
    /// An instance that represents a prompt.
    @PromptBuilder var ompPromptRepresentation: Prompt { get }
  }
}

extension String: OMP.PromptRepresentable {
  public var ompPromptRepresentation: OMP.Prompt {
    // Use the *base* initializer that doesn't recurse
    OMP.Prompt(_internal: self)
  }
}

extension Array: OMP.PromptRepresentable where Element: OMP.PromptRepresentable {
  public var ompPromptRepresentation: OMP.Prompt {
    self.map { $0.ompPromptRepresentation._internal }.joined(separator: "\n")
  }
}

