import Testing

@testable import ClaudeZellijWhipCore

@Suite("parseArg")
struct ParseArgTests {
  @Test("returns value for matching flag")
  func matchingFlag() {
    let result = parseArg(["--title", "Hello"], flag: "--title")
    #expect(result == "Hello")
  }

  @Test("returns nil when flag not present")
  func missingFlag() {
    let result = parseArg(["--title", "Hello"], flag: "--message")
    #expect(result == nil)
  }

  @Test("returns nil when flag is last element (no value)")
  func flagWithoutValue() {
    let result = parseArg(["--title"], flag: "--title")
    #expect(result == nil)
  }

  @Test("returns first match when flag appears multiple times")
  func duplicateFlag() {
    let result = parseArg(["--title", "First", "--title", "Second"], flag: "--title")
    #expect(result == "First")
  }

  @Test("returns nil for empty args")
  func emptyArgs() {
    let result = parseArg([], flag: "--title")
    #expect(result == nil)
  }

  @Test("handles multiple different flags")
  func multipleFlags() {
    let args = ["--title", "MyTitle", "--message", "MyMessage", "--folder", "MyFolder"]
    #expect(parseArg(args, flag: "--title") == "MyTitle")
    #expect(parseArg(args, flag: "--message") == "MyMessage")
    #expect(parseArg(args, flag: "--folder") == "MyFolder")
  }

  @Test("value can contain spaces")
  func valueWithSpaces() {
    let result = parseArg(["--message", "Hello World"], flag: "--message")
    #expect(result == "Hello World")
  }

  @Test("does not match partial flag names")
  func partialFlagName() {
    let result = parseArg(["--title-extra", "Value"], flag: "--title")
    #expect(result == nil)
  }

  @Test("flag value can look like another flag")
  func flagAsValue() {
    let result = parseArg(["--title", "--message"], flag: "--title")
    #expect(result == "--message")
  }
}
