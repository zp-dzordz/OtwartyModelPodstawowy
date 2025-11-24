
#if canImport(UIKit)
import UIKit
import CoreImage
#endif

#if canImport(AppKit)
import AppKit
import CoreImage
#endif

import OMPCore
import MLXLMCommon
import MLXVLM
import SwiftGrammarMLX
import Tokenizers

/// A language model that runs locally using MLX.
///
/// Use this model to run language models on Apple silicon using the MLX framework.
/// Models are automatically downloaded and cached when first used.
///
/// ```swift
/// let model = MLXLanguageModel(modelId: "mlx-community/Llama-3.2-3B-Instruct-4bit")
/// ```
public struct MLXLanguageModel: OMP.LanguageModel {
  
  /// The reason the model is unavailable.
  // TODO - check availability regarding iOS version / hardware revision
  // For now assume this model is always available
  public typealias UnavailableReason = Never
  
  /// The model identifier from the MLX community on Hugging Face.
  public let modelId: String
  
  /// Creates an MLX language model.
  ///
  /// - Parameter modelId: The Hugging Face model identifier (for example, "mlx-community/Llama-3.2-3B-Instruct-4bit").
  public init(modelId: String) {
    self.modelId = modelId
  }
  
  public func respond<Content>(
    within session: OMP.LanguageModelSession,
    to prompt: OMP.Prompt,
    generating type: Content.Type,
    includeSchemaInPrompt: Bool,
    options: OMP.GenerationOptions
  ) async throws -> OMP.LanguageModelSession.Response<Content> where Content : OMP.Generable {
    
    // TODO: track model loading progress
    let context = try await loadModel(id: modelId) { progress in
      print("Progress : \(progress.fractionCompleted * 100)")
    }
    
    // Convert session tools to MLX ToolSpec format
    let toolSpecs: [ToolSpec]? = session.tools.isEmpty
    ? nil
    : session.tools.map { tool in
      convertToolToMLXSpec(tool)
    }
    
    // Map OMP.GenerationOptions to MLX.GenerateParameters
    let generateParameters = toGenerateParameters(options)
    
    // Start with user prompt
    let userSegments = extractPromptSegment(from: session, fallbackText: prompt.description)
    let userMessage = convertSegmentsToMLXMessage(userSegments)
    var chat: [MLXLMCommon.Chat.Message] = [userMessage]
    var allTextChunks: [String] = []
    var allEntries: [OMP.Transcript.Entry] = []
    
    let schema = type.ompGenerationSchema.jsonSchema
    let sampler = generateParameters.sampler()
    let grammar = try SwiftGrammar.schema(schema)
    let processor = try await GrammarMaskedLogitProcessor.from(configuration: context.configuration, grammar: grammar)

    // Loop until no more tool calls
    while true {
      // Build user input with current chat history and tools
      let userInput = MLXLMCommon.UserInput(
        chat: chat,
        tools: toolSpecs
      )
      let lmInput = try await context.processor.prepare(input: userInput)
      let iterator = try TokenIterator(input: lmInput, model: context.model, processor: processor, sampler: sampler)
      let stream = MLXLMCommon.generate(input: lmInput, context: context, iterator: iterator)
      
      var chunks: [String] = []
      var collectedToolCalls: [MLXLMCommon.ToolCall] = []
      
      for await item in stream {
        switch item {
        case .chunk(let text):
          chunks.append(text)
        case .info:
          break
        case .toolCall(let call):
          collectedToolCalls.append(call)
        }
      }
      
      let assistantText = chunks.joined()
      allTextChunks.append(assistantText)
      
      // Add assistant response to chat history
      if !assistantText.isEmpty {
        chat.append(.assistant(assistantText))
      }
      
      // If there are tool calls, execute them and continue
      #warning("Implement response tool calls")
      if !collectedToolCalls.isEmpty {}
      
      // No more tool calls, exit loop
      break
    }
    
    let text = allTextChunks.joined()
    
    fatalError()
  }
  
  // MARK: - Tool Conversion
  private func convertToolToMLXSpec(_ tool: any OMP.Tool) -> ToolSpec {
#warning("Implement convertToolToMLXSpec")
    let parametersDict: [String: Any]
    fatalError("Not implemented")
  }
  
  // MARK: - Options Mapping
  private func toGenerateParameters(_ options: OMP.GenerationOptions) -> MLXLMCommon.GenerateParameters {
    MLXLMCommon.GenerateParameters(
      maxTokens: options.maximumResponseTokens,
      maxKVSize: nil,
      kvBits: nil,
      kvGroupSize: 64,
      quantizedKVStart: 0,
      temperature: Float(options.temperature ?? 0.6),
      topP: 1.0,
      repetitionPenalty: nil,
      repetitionContextSize: 20
    )
  }
  
  // MARK: - Segment Extraction
  private func extractPromptSegment(from session: OMP.LanguageModelSession, fallbackText: String) -> [OMP.Transcript.Segment] {
    // Prefer the most recent Transcript.Prompt entry if present
    for entry in session.transcript.reversed() {
      if case .prompt(let p) = entry {
        return p.segments
      }
    }
    return [.text(.init(content: fallbackText))]
  }
  
  private func convertSegmentsToMLXMessage(_ segments: [OMP.Transcript.Segment]) -> MLXLMCommon.Chat.Message {
    var textParts: [String] = []
    var images: [MLXLMCommon.UserInput.Image] = []
    
    for segment in segments {
      switch segment {
      case .text(let text):
        textParts.append(text.content)
      case .structure(let structured):
        textParts.append(structured.content.jsonString)
      case .image(let imageSegment):
        switch imageSegment.source {
        case .url(let url):
          images.append(.url(url))
        case .data(let data, _):
#if canImport(UIKit)
          if let uiImage = UIKit.UIImage(data: data),
             let ciImage = CIImage(image: uiImage)
          {
            images.append(.ciImage(ciImage))
          }
#elseif canImport(AppKit)
          if let nsImage = AppKit.NSImage(data: data),
             let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            let ciImage = CIImage(cgImage: cgImage)
            images.append(.ciImage(ciImage))
          }
#endif
        }
      }
    }
    
    let content = textParts.joined(separator: "\n")
    return MLXLMCommon.Chat.Message(role: .user, content: content, images: images)
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
