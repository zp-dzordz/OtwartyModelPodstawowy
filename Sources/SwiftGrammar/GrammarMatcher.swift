import MLX

public protocol GrammarMatcher {
  func nextTokenMask() -> MLXArray // 0 or -infinity
  func advance(token: MLXArray)
  func reset()
}

