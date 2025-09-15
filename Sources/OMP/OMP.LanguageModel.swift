import MLX
import MLXLLM
import MLXLMCommon
import Observation

extension OMP {
  @Observable
  @MainActor
  public final class Model {
    enum LoadingError: Error {
        case modelNotFound(String)
    }
    var info = ""
    var modelConfiguration = ModelConfiguration.defaultModel
    var progress = 0.0
    
    enum State {
      case idle
      case loaded(ModelContainer)
    }
    
    var loadState: State = .idle
    
    func load() async throws -> ModelContainer {
//      guard let modelConfiguration = ModelConfiguration.getModelByName(modelName) else {
//        throw LoadingError.modelNotFound(modelName)
//      }
      switch loadState {
      case .idle:
        // limit the buffer cache
        MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)
        
        let modelContainer = try await LLMModelFactory.shared.loadContainer(configuration: modelConfiguration) { [modelConfiguration] progress in
          Task { @MainActor in
            self.info = "Downloading \(modelConfiguration.name): \(Int(progress.fractionCompleted * 100))%"
            self.progress = progress.fractionCompleted
          }
        }
        info = "Loaded \(modelConfiguration.id). Weigths: \(MLX.GPU.activeMemory / 1024 / 1024)M"
        loadState = .loaded(modelContainer)
        return modelContainer
      
      case let .loaded(modelContainer):
        return modelContainer
      }
    }
  }
}

