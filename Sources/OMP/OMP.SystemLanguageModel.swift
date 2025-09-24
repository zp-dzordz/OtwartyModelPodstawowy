import MLX
import MLXLLM
import MLXLMCommon
import Observation

actor LanguageModelLoader {
  enum LoadingError: Error {
    case modelNotFound(String)
  }
  private enum State {
    case idle
    case loaded(ModelContainer)
  }
  var modelConfiguration: ModelConfiguration {
    get {
      ModelConfiguration.defaultModel
    }
  }
  private var loadState: State = .idle
  @MainActor
  var info: String?
  @MainActor
  var progress = 0.0
    
  func load() async throws -> ModelContainer {
    switch loadState {
    case .idle:
      // limit the buffer cache
      MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)
      
      let modelContainer = try await LLMModelFactory.shared.loadContainer(
        configuration: modelConfiguration
      ) { [modelConfiguration] progress in
        Task { @MainActor in
          self.info = "Downloading \(modelConfiguration.name): \(Int(progress.fractionCompleted * 100))%"
          self.progress = progress.fractionCompleted
        }
      }
      let configurationId = modelConfiguration.id
      let weightsSize = MLX.GPU.activeMemory / 1024 / 1024
      Task { @MainActor in
        info = "Loaded \(configurationId). Weigths: \(weightsSize)M"

      }
      loadState = .loaded(modelContainer)
      return modelContainer
    case let .loaded(modelContainer):
      return modelContainer
    }
  }
}

@available(iOS 13.0, macOS 15.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension OMP {
  public final class SystemLanguageModel: Sendable {
    let loader: LanguageModelLoader
    
    init(loader: LanguageModelLoader) {
      self.loader = loader
    }
    public static let `default`: SystemLanguageModel = .init(loader: .init())
  }
}

