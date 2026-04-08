import Foundation
import Testing

@testable import ClaudeZellijWhipCore

@Suite("notificationIdentifier", .serialized)
struct NotificationIdentifierTests {
  @Test("builds identifier from session and pane environment variables")
  func withSessionAndPane() {
    setenv("ZELLIJ_SESSION_NAME", "my-session", 1)
    setenv("ZELLIJ_PANE_ID", "42", 1)
    defer {
      unsetenv("ZELLIJ_SESSION_NAME")
      unsetenv("ZELLIJ_PANE_ID")
    }

    #expect(notificationIdentifier() == "claude-prompt-my-session-42")
  }

  @Test("uses empty strings when env vars are unset")
  func withoutEnvVars() {
    unsetenv("ZELLIJ_SESSION_NAME")
    unsetenv("ZELLIJ_PANE_ID")

    #expect(notificationIdentifier() == "claude-prompt--")
  }

  @Test("handles only session set")
  func onlySession() {
    setenv("ZELLIJ_SESSION_NAME", "test-session", 1)
    unsetenv("ZELLIJ_PANE_ID")
    defer { unsetenv("ZELLIJ_SESSION_NAME") }

    #expect(notificationIdentifier() == "claude-prompt-test-session-")
  }

  @Test("handles only pane set")
  func onlyPane() {
    unsetenv("ZELLIJ_SESSION_NAME")
    setenv("ZELLIJ_PANE_ID", "7", 1)
    defer { unsetenv("ZELLIJ_PANE_ID") }

    #expect(notificationIdentifier() == "claude-prompt--7")
  }

  @Test("is deterministic across calls with same env")
  func deterministic() {
    setenv("ZELLIJ_SESSION_NAME", "s", 1)
    setenv("ZELLIJ_PANE_ID", "1", 1)
    defer {
      unsetenv("ZELLIJ_SESSION_NAME")
      unsetenv("ZELLIJ_PANE_ID")
    }

    let first = notificationIdentifier()
    let second = notificationIdentifier()
    #expect(first == second)
  }

  @Test("different sessions produce different identifiers")
  func differentSessions() {
    setenv("ZELLIJ_PANE_ID", "1", 1)
    defer { unsetenv("ZELLIJ_PANE_ID") }

    setenv("ZELLIJ_SESSION_NAME", "session-a", 1)
    let a = notificationIdentifier()

    setenv("ZELLIJ_SESSION_NAME", "session-b", 1)
    let b = notificationIdentifier()

    unsetenv("ZELLIJ_SESSION_NAME")

    #expect(a != b)
  }

  @Test("different panes produce different identifiers")
  func differentPanes() {
    setenv("ZELLIJ_SESSION_NAME", "s", 1)
    defer { unsetenv("ZELLIJ_SESSION_NAME") }

    setenv("ZELLIJ_PANE_ID", "1", 1)
    let a = notificationIdentifier()

    setenv("ZELLIJ_PANE_ID", "2", 1)
    let b = notificationIdentifier()

    unsetenv("ZELLIJ_PANE_ID")

    #expect(a != b)
  }
}
