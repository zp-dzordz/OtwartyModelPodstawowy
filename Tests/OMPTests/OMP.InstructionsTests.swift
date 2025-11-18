import Foundation
import Testing
@testable import OMPCore

struct InstructionsTests {
  @Test func stringConformanceYieldsContent() {
    let s = "Say hello".ompInstructionsRepresentation
    #expect(s._internal == "Say hello")
  }
  
  @Test func builderConcatenatesMultipleComponents() {
    let instr = OMP.Instructions {
      "First instruction"
      "Second instruction"
      "Third instruction"
    }
    #expect(instr._internal.contains("First instruction"))
    #expect(instr._internal.contains("Second instruction"))
    #expect(instr._internal.contains("Third instruction"))
  }
  
  @Test func optionalBuilderComponentYieldsEmptyWhenNil() {
    let maybe: OMP.Instructions? = nil
    let instr = OMP.Instructions {
      if let _ = maybe {
        "present"
      }
    }
    #expect(instr._internal == "")
  }
  
  @Test func eitherBuilderSelectsFirstBranch() {
    let instr = OMP.Instructions {
      if true {
        "branch A"
      }
      else {
        "branch B"
      }
    }
    #expect(instr._internal.contains("branch A"))
    #expect(!instr._internal.contains("branch B"))
  }
  
  @Test func eitherBuilderSelectsSecondBranch() {
    let instr = OMP.Instructions {
      if false {
        "branch A"
      } else {
        "branch B"
      }
    }
    #expect(instr._internal.contains("branch B"))
    #expect(!instr._internal.contains("branch A"))
  }
  
  @Test func arrayBuilderCombinesElements() {
    let arr: [OMP.Instructions] = ["a", "b", "c"].map { OMP.Instructions(_internal: $0) }
    let instr = OMP.InstructionsBuilder.buildArray(arr)
    #expect(instr._internal.contains("a"))
    #expect(instr._internal.contains("b"))
    #expect(instr._internal.contains("c"))
  }
}

