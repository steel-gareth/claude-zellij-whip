import AppKit
import ClaudeZellijWhipCore
import OSLog

private let log = Logger(subsystem: "dev.steel-gareth.claude-zellij-whip", category: "main")

let app = NSApplication.shared
let args = CommandLine.arguments
let mode = args.count > 1 ? args[1] : "listen"

log.info("claude-zellij-whip \(appVersion, privacy: .public) (build \(buildNumber, privacy: .public)) mode=\(mode, privacy: .public)")

if args.count > 1 && args[1] == "notify" {
  Task {
    await sendNotification(args: Array(args.dropFirst(2)))
    try? await Task.sleep(for: .milliseconds(500))
    await MainActor.run { app.terminate(nil) }
  }
  app.run()
} else if args.count > 1 && args[1] == "clear" {
  Task {
    await clearNotification(all: args.contains("--all"))
    await MainActor.run { app.terminate(nil) }
  }
  app.run()
} else {
  let delegate = AppDelegate()
  app.delegate = delegate
  app.run()
}
