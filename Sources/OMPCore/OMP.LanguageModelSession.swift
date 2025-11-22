import Foundation
import Schema
import SwiftGrammar

extension OMP {
  @available(iOS 13.0, macOS 15.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  final public class LanguageModelSession {

    /// A full history of interactions, including user inputs and model responses.
    final public private(set) var transcript: Transcript
    
    /// A Boolean value that indicates a response is being generated.
    ///
    /// - Important: You should not call any of the respond methods while
    /// this property is `true`.
    ///
    /// Disable buttons and other interactions to prevent users from submitting
    /// a second prompt while the model is responding to their first prompt.
    ///
    /// ```swift
    /// struct ShopView: View {
    ///     @State var session = LanguageModelSession()
    ///     @State var joke = ""
    ///
    ///     var body: some View {
    ///         Text(joke)
    ///         Button("Generate joke") {
    ///             Task {
    ///                 assert(!session.isResponding, "It should not be possible to tap this button while the model is responding")
    ///                 joke = try await session.respond(to: "Tell me a joke").content
    ///             }
    ///         }
    ///         .disabled(session.isResponding) // Prevent concurrent calls to respond
    ///     }
    /// }
    /// ```
    final public private(set) var isResponding: Bool = false

    /// Start a new session in blank slate state with string-based instructions.
    ///
    /// - Parameters
    ///   - model: The language model to use for this session.
    ///   - tools: Tools to make available to the model for this session.
    ///   - instructions: Instructions that control the model's behavior.
    public convenience init(
      model: any LanguageModel,
      tools: [any Tool] = [],
      instructions: Instructions? = nil
    ) {
      self.init(
        model: model,
        tools: tools,
        instructions: instructions
      )
    }
    
    /// Start a new session in blank slate state with instructions builder.
    ///
    /// - Parameters
    ///   - model: The language model to use for this session.
    ///   - tools: Tools to make available to the model for this session.
    ///   - instructions: Instructions that control the model's behavior.
    public convenience init(
      model: any LanguageModel,
      tools: [any Tool] = [],
      @InstructionsBuilder instructions: () throws -> Instructions
    ) rethrows {
      try self.init(model: model, tools: tools, instructions: instructions())
    }
    
    private init(
      model: any LanguageModel,
      tools: [any Tool] = [],
      instructions: Instructions? = nil,
      transcript: Transcript
    ) {
      self.model = model
      self.tools = tools
      self.instructions = instructions
      
      // Build transcript with instructions if provided and not already in transcript
      var finalTranscript = transcript
      if let instructions = instructions {
        // Only add instructions if transcript doesn't already start with instructions
        let hasInstructions = finalTranscript.first.map { entry in
          if case .instructions = entry { return true } else { return false }
        } ?? false
        
        if !hasInstructions {
          let instructionEntry = Transcript.Entry.instructions(
            Transcript.Instructions(
              segments: [.text(.init(content: instructions._internal))],
              toolDefinitions: tools.map { Transcript.ToolDefinition(tool: $0) }
            )
          )
          finalTranscript.append(instructionEntry)
        }
      }
      self.transcript = finalTranscript
    }
    /// Requests that the system eagerly load the resources required for this session into memory and
    /// optionally caches a prefix of your prompt.
    ///
    /// This method can be useful in cases where you have a strong signal that the user will interact with
    /// session within a few seconds. For example, you might call prewarm when the user begins typing
    /// into a text field.
    ///
    /// If you know a prefix for the future prompt, passing it to prewarm will allow the system to process the
    /// prompt eagerly and reduce latency for the future request.
    ///
    /// - Important: You should only use prewarm when you have a window of at least 1s before the
    /// call to `respond(to:)`.
    ///
    /// - Note: Calling this method does not guarantee that the system loads your assets immediately,
    /// particularly if your app is running in the background or the system is under load.
    public func prewarm(promptPrefix: Prompt? = nil) {
      model.prewarm(for: self, promptPrefix: promptPrefix)
    }
    
    nonisolated private func beginResponding() async {
      let count = await respondingState.increment()
      let active = count > .zero
      await MainActor.run {
        self.isResponding = active
      }
    }
    
    nonisolated private func endResponding() async {
      let count = await respondingState.decrement()
      let active = count > .zero
      await MainActor.run {
        self.isResponding = active
      }
    }
    
    nonisolated private func wrapRespond<T>(_ operation: () async throws -> T) async throws -> T {
      await beginResponding()
      do {
        let result = try await operation()
        await endResponding()
        return result
      } catch {
        await endResponding()
        throw error
      }
    }
    
    
    @available(iOS 13.0, macOS 15.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public struct Response<Content> where Content: Generable {
      /// The response content
      public let content: Content
      
      /// The raw response content.
      ///
      /// When `Content` is `GeneratedContent`, this is the same as `content`.
      public let rawContent: GeneratedContent
      
      /// The list of transcript entries.
      public let transcriptEntries: ArraySlice<Transcript.Entry>
    }

    /// Produces a generable object as a response to a prompt.
    ///
    /// Consider using the default value of `true` for `includeSchemaInPrompt`.
    /// The exception to the rule is when the model has knowledge about the expected response format, either
    /// because it has been trained on it, or because it has seen exhaustive examples during this session.
    ///
    /// - Parameters:
    ///   - prompt: A prompt for the model to respond to.
    ///   - type: A type to produce as the response.
    ///   - includeSchemaInPrompt: Inject the schema into the prompt to bias the model.
    ///   - options: Options that control how tokens are sampled from the distribution the model produces.
    /// - Returns: ``GeneratedContent`` containing the fields and values defined in the schema.
    @discardableResult
    nonisolated(nonsending) final public func respond<Content>(
      to prompt: Prompt,
      generating type: Content.Type = Content.self,
      includeSchemaInPrompt: Bool = true,
      options: GenerationOptions = GenerationOptions()
    ) async throws -> LanguageModelSession.Response<Content> where Content : Generable {
      try await wrapRespond {
        // Add prompt to transcript
        let promptEntry = Transcript.Entry.prompt(
          Transcript.Prompt(
            segments: [.text(.init(content: prompt._internal))],
            options: options,
            responseFormat: nil
          )
        )
        await MainActor.run {
          self.transcript.append(promptEntry)
        }
        
        let response = try await model.respond(
          within: self,
          to: prompt,
          generating: type,
          includeSchemaInPrompt: includeSchemaInPrompt,
          options: options
        )
        
        self.transcript.append(contentsOf: response.transcriptEntries)
        
        return response
      }
    }
    
    private var instructions: Instructions?
    private let model: any LanguageModel
    private let tools: [any Tool]
    private let respondingState = RespondingState()
  }
}

// MARK: - String Response Convenience Methods
extension OMP.LanguageModelSession {
  /// Produces a response to a prompt.
  ///
  /// - Parameters:
  ///   - prompt: A prompt for the model to respond to.
  ///   - options: GenerationOptions that control how tokens are sampled from the distribution the model produces.
  /// - Returns: A string composed of the tokens produced by sampling model output.
  @discardableResult
  nonisolated(nonsending) final public func respond(
    to prompt: OMP.Prompt,
    options: OMP.GenerationOptions = OMP.GenerationOptions()
  ) async throws -> OMP.LanguageModelSession.Response<String> {
    try await respond(
      to: prompt,
      generating: String.self,
      includeSchemaInPrompt: true,
      options: options
    )
  }
}

@available(iOS 13.0, macOS 15.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension OMP.LanguageModelSession: @unchecked Sendable {}

@available(iOS 17.0, macOS 15.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension OMP.LanguageModelSession: nonisolated Observable {}

extension OMP {
  private actor RespondingState {
    private var count = 0
    
    func increment() -> Int {
      count += 1
      return count
    }
    
    func decrement() -> Int {
      count = max(0, count - 1)
      return count
    }
  }
}

//@available(iOS 13.0, macOS 15.0, *)
//@available(tvOS, unavailable)
//@available(watchOS, unavailable)
//func generate(
//  input: LMInput,
//  parameters: GenerateParameters = GenerateParameters(),
//  context: ModelContext,
//  grammar: SwiftGrammar,
//  didGenerate: ([Int]) -> GenerateDisposition = { _ in .more }
//) async throws -> GenerateResult {
//  let sampler = parameters.sampler()
//  let processor = try await GrammarMaskedLogitProcessor.from(configuration: context.configuration, grammar: grammar)
//  let iterator = try TokenIterator(input: input, model: context.model, processor: processor, sampler: sampler)
//  let result = MLXLMCommon.generate(input: input, context: context, iterator: iterator, didGenerate: didGenerate)
//  return result
//}
//
//
//@available(iOS 13.0, macOS 15.0, *)
//@available(tvOS, unavailable)
//@available(watchOS, unavailable)
//func generate<Content: OMP.Generable>(
//  input: LMInput,
//  parameters: GenerateParameters = GenerateParameters(),
//  context: ModelContext,
//  schema: JSONSchema,
//  generating: Content.Type,
//  indent: Int? = nil,
//  didGenerate: ([Int]) -> GenerateDisposition = {_ in .more }
//) async throws -> (GenerateResult, Content) {
//  let grammar = try SwiftGrammar.schema(schema, indent: indent)
//  let sampler = parameters.sampler()
//  let processor = try await GrammarMaskedLogitProcessor.from(configuration: context.configuration, grammar: grammar)
//  let iterator = try TokenIterator(input: input, model: context.model, processor: processor, sampler: sampler)
//  let result = MLXLMCommon.generate(input: input, context: context, iterator: iterator, didGenerate: didGenerate)
//
//
//
//  print(result.output)
//  fatalError()
////  let content = try JSONDecoder().decode(Content.self, from: Data(result.output.utf8))
////  return (result, content)
//}
