import Foundation
import MLX
import MLXLLM
import MLXLMCommon
import Hub

struct ModelInfo: Sendable {
  var id: String
  var revision: String
  var extraEOSTokens: Set<String>?
  
  init(id: String, revision: String, extraEOSTokens: Set<String>? = nil) {
    self.id = id
    self.revision = revision
    self.extraEOSTokens = extraEOSTokens
  }
}

struct MLXLanguageModelLoader: Sendable {
  let progress: @Sendable () -> AsyncStream<Float>
  var load: @Sendable ()  async throws -> ModelContainer?
}

extension MLXLanguageModelLoader {
  static func liveValue(info: ModelInfo) -> Self {
    let (progressStream, progressContinuation) = AsyncStream<Float>.makeStream()
    return .init(progress: {
      progressStream
    }, load: {
      let hub = HubApi(useOfflineMode: false)
      let configuration = ModelConfiguration(id: info.id, revision: info.revision, extraEOSTokens: info.extraEOSTokens ?? [])
      let context =  try await LLMModelFactory.shared.load(
        hub: hub,
        configuration: configuration) { progress in
          print(progress.fractionCompleted * 100, " %")
          progressContinuation.yield(Float(progress.fractionCompleted) * 100)
      }
      return .init(context: context)
    })
  }
}



//@MainActor
//@Observable
//class LanguageModelLoader {
//  enum LoadingError: Error {
//    case modelNotFound(String)
//  }
//  private enum State {
//    case idle
//    case loaded(ModelContainer)
//  }
//  var modelConfiguration: ModelConfiguration {
//    get {
//      ModelConfiguration.defaultModel
//    }
//  }
//  private var loadState: State = .idle
//  var info: String?
//  var progress = 0.0
//    
//  func load() async throws -> ModelContainer {
//    switch loadState {
//    case .idle:
//      // limit the buffer cache
//      MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)
//      
//      let modelContainer = try await LLMModelFactory.shared.loadContainer(
//        configuration: modelConfiguration
//      ) { [modelConfiguration] progress in
//        Task { @MainActor in
//          self.info = "Downloading \(modelConfiguration.name): \(Int(progress.fractionCompleted * 100))%"
//          self.progress = progress.fractionCompleted
//        }
//      }
//      let configurationId = modelConfiguration.id
//      let weightsSize = MLX.GPU.activeMemory / 1024 / 1024
//      Task { @MainActor in
//        info = "Loaded \(configurationId). Weigths: \(weightsSize)M"
//
//      }
//      loadState = .loaded(modelContainer)
//      return modelContainer
//    case let .loaded(modelContainer):
//      return modelContainer
//    }
//  }
//}

@available(iOS 13.0, macOS 15.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension OMP {
  public final class SystemLanguageModel: Sendable {
    let loader: MLXLanguageModelLoader
    
    init(loader: MLXLanguageModelLoader) {
      self.loader = loader
    }
    public static let `default`: SystemLanguageModel = .init(
      loader: .liveValue(
        info: .init(
          id: "vqstudio/Bielik-1.5B-v3.0-Instruct-MLX-4bit",
          revision: "main"
        )
      )
    )
  }
}

