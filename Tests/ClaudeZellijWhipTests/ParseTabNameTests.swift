import Testing

@testable import ClaudeZellijWhipCore

@Suite("parseTabName")
struct ParseTabNameTests {
  @Test("extracts focused tab name from layout")
  func basicFocusedTab() {
    let layout = """
      <layout>
        <tab name="editor" focus=true>
          <pane />
        </tab>
      </layout>
      """
    #expect(parseTabName(from: layout) == "editor")
  }

  @Test("picks the focused tab among multiple tabs")
  func multipleTabs() {
    let layout = """
      <layout>
        <tab name="logs">
          <pane />
        </tab>
        <tab name="claude" focus=true>
          <pane />
        </tab>
        <tab name="build">
          <pane />
        </tab>
      </layout>
      """
    #expect(parseTabName(from: layout) == "claude")
  }

  @Test("returns nil when no tab is focused")
  func noFocusedTab() {
    let layout = """
      <layout>
        <tab name="editor">
          <pane />
        </tab>
      </layout>
      """
    #expect(parseTabName(from: layout) == nil)
  }

  @Test("returns nil for empty string")
  func emptyInput() {
    #expect(parseTabName(from: "") == nil)
  }

  @Test("returns nil for invalid XML")
  func invalidInput() {
    #expect(parseTabName(from: "not xml at all") == nil)
  }

  @Test("handles tab name with spaces")
  func tabNameWithSpaces() {
    let layout = #"<tab name="my tab" focus=true>"#
    #expect(parseTabName(from: layout) == "my tab")
  }

  @Test("handles tab name with special characters")
  func tabNameWithSpecialChars() {
    let layout = #"<tab name="claude-code (2)" focus=true>"#
    #expect(parseTabName(from: layout) == "claude-code (2)")
  }

  @Test("ignores focus=false")
  func focusFalse() {
    let layout = #"<tab name="editor" focus=false>"#
    #expect(parseTabName(from: layout) == nil)
  }

  @Test("handles extra attributes between name and focus")
  func extraAttributes() {
    let layout = #"<tab name="editor" position="1" size="50" focus=true>"#
    #expect(parseTabName(from: layout) == "editor")
  }

  @Test("returns first focused tab if multiple are focused")
  func multiplesFocused() {
    let layout = """
      <tab name="first" focus=true>
      </tab>
      <tab name="second" focus=true>
      </tab>
      """
    #expect(parseTabName(from: layout) == "first")
  }

  @Test("handles realistic zellij dump-layout output")
  func realisticLayout() {
    let layout = """
      <layout>
        <tab name="Tab #1" position="0">
          <pane borderless=true size="50%" split_direction="horizontal">
            <pane focus=true />
          </pane>
        </tab>
        <tab name="Tab #2" position="1" focus=true>
          <pane size="100%">
            <pane focus=true />
          </pane>
        </tab>
      </layout>
      """
    #expect(parseTabName(from: layout) == "Tab #2")
  }
}
