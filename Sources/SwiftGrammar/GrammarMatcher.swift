#if MLX
import MLX
#endif

public protocol GrammarMatcher {
#if MLX
  func nextTokenMask() -> MLXArray // 0 or -infinity
  func advance(token: MLXArray)
  func reset()
#endif
}

