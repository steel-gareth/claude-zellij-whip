import Foundation
import Testing

@testable import ClaudeZellijWhipCore

@Suite("findZellijPath")
struct ZellijPathTests {
  @Test("returns a path that exists on this system, or nil")
  func returnsValidPathOrNil() {
    let result = findZellijPath()
    if let path = result {
      #expect(FileManager.default.fileExists(atPath: path))
      #expect(path.hasSuffix("/zellij"))
    }
  }

  @Test("checks known paths in order")
  func knownPaths() {
    let result = findZellijPath()
    let knownPaths = [
      "/opt/homebrew/bin/zellij",
      "/usr/local/bin/zellij",
      "/usr/bin/zellij",
    ]
    if let result {
      #expect(knownPaths.contains(result))
    }
  }
}
