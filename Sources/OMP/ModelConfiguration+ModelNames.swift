import MLXLMCommon

extension ModelConfiguration {
  public static let bielik_7b_instruct = ModelConfiguration(
      id: "speakleash/Bielik-7B-Instruct-v0.1-MLX"
  )
  
  public static let availableModels: [ModelConfiguration] = [
    bielik_7b_instruct,
  ]

  public static var defaultModel: ModelConfiguration {
    bielik_7b_instruct
  }
  
  public static func getModelByName(_ name: String) -> ModelConfiguration? {
      if let model = availableModels.first(where: { $0.name == name }) {
          return model
      } else {
          return nil
      }
  }
}

