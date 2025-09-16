import MLXLMCommon

extension ModelConfiguration {
  public static let llama_3_2_1b_4bit = ModelConfiguration(
      id: "speakleash/Bielik-7B-Instruct-v0.1-MLX"
  )

  public static let llama_3_2_3b_4bit = ModelConfiguration(
      id: "mlx-community/Llama-3.2-3B-Instruct-4bit"
  )

  public static let deepseek_r1_distill_qwen_1_5b_4bit = ModelConfiguration(
      id: "mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-4bit"
  )

  public static let deepseek_r1_distill_qwen_1_5b_8bit = ModelConfiguration(
      id: "mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-8bit"
  )

  public static let qwen_3_4b_4bit = ModelConfiguration(
      id: "mlx-community/Qwen3-4B-4bit"
  )

  public static let qwen_3_8b_4bit = ModelConfiguration(
      id: "mlx-community/Qwen3-8B-4bit"
  )
  
  public static let availableModels: [ModelConfiguration] = [
      llama_3_2_1b_4bit,
      llama_3_2_3b_4bit,
      deepseek_r1_distill_qwen_1_5b_4bit,
      deepseek_r1_distill_qwen_1_5b_8bit,
      qwen_3_4b_4bit,
      qwen_3_8b_4bit,
  ]

  public static var defaultModel: ModelConfiguration {
      llama_3_2_1b_4bit
  }
  
  public static func getModelByName(_ name: String) -> ModelConfiguration? {
      if let model = availableModels.first(where: { $0.name == name }) {
          return model
      } else {
          return nil
      }
  }
}

