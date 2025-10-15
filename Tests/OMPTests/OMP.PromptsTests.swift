import Foundation
import Testing
@testable import OMP

struct PromptsTests {
  @Test func stringConformanceYieldsContent() {
    let s = "Say hello".ompPromptRepresentation
    #expect(s._internal == "Say hello")
  }
  
  @Test func builderConcatenatesMultipleComponents() {
    let prompt = OMP.Prompt {
      "First prompt"
      "Second prompt"
      "Third prompt"
    }
    #expect(prompt._internal.contains("First prompt"))
    #expect(prompt._internal.contains("Second prompt"))
    #expect(prompt._internal.contains("Third prompt"))
  }
  
  @Test func optionalBuilderComponentYieldsEmptyWhenNil() {
    let maybe: OMP.Prompt? = nil
    let prompt = OMP.Prompt {
      if let _ = maybe {
        "present"
      }
    }
    #expect(prompt._internal == "")
  }
  
  @Test func eitherBuilderSelectsFirstBranch() {
    let prompt = OMP.Prompt {
      if true {
        "branch A"
      }
      else {
        "branch B"
      }
    }
    #expect(prompt._internal.contains("branch A"))
    #expect(!prompt._internal.contains("branch B"))
  }
  
  @Test func eitherBuilderSelectsSecondBranch() {
    let prompt = OMP.Prompt {
      if false {
        "branch A"
      } else {
        "branch B"
      }
    }
    #expect(prompt._internal.contains("branch B"))
    #expect(!prompt._internal.contains("branch A"))
  }
  
  @Test func arrayBuilderCombinesElements() {
    let arr: [OMP.Prompt] = ["a", "b", "c"].map { OMP.Prompt(_internal: $0) }
    let prompt = OMP.PromptBuilder.buildArray(arr)
    #expect(prompt._internal.contains("a"))
    #expect(prompt._internal.contains("b"))
    #expect(prompt._internal.contains("c"))
  }
}
