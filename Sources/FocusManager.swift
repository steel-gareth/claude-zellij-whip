import AppKit
import ApplicationServices
import OSLog
import PrivateAPI

private let log = Logger(subsystem: "dev.rvcas.claude-zellij-whip", category: "focus")

func focusGhostty(windowID: UInt32? = nil) {
  log.info("focusGhostty called with windowID: \(windowID.map { String($0) } ?? "nil")")

  guard let ghostty = NSWorkspace.shared.runningApplications
    .first(where: { $0.bundleIdentifier == "com.mitchellh.ghostty" })
  else {
    log.warning("Ghostty not found in running applications")
    return
  }

  if let windowID = windowID,
    raiseGhosttyWindow(pid: ghostty.processIdentifier, windowID: windowID)
  {
    log.info("Raised specific window \(windowID), activating Ghostty")
    ghostty.activate(options: [.activateIgnoringOtherApps])
  } else {
    log.info("Falling back to activate all windows")
    ghostty.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
  }
}

private func raiseGhosttyWindow(pid: pid_t, windowID: UInt32) -> Bool {
  guard AXIsProcessTrusted() else {
    log.warning("Accessibility not trusted — cannot raise specific window")
    return false
  }

  let appElement = AXUIElementCreateApplication(pid)
  var windowsValue: CFTypeRef?
  guard
    AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsValue)
      == .success,
    let windows = windowsValue as? [AXUIElement]
  else {
    log.error("Failed to get AX windows for raise")
    return false
  }

  log.info("Searching \(windows.count) windows for windowID \(windowID)")

  for window in windows {
    var axWindowID: UInt32 = 0
    guard _AXUIElementGetWindow(window, &axWindowID) == .success else { continue }
    if axWindowID == windowID {
      AXUIElementPerformAction(window, kAXRaiseAction as CFString)
      log.info("Found and raised window \(windowID)")
      return true
    }
  }

  log.warning("Window \(windowID) not found among current windows")
  return false
}

func findGhosttyWindowID(session: String?) -> UInt32? {
  log.info("findGhosttyWindowID called with session: \(session ?? "nil")")

  guard let session = session, !session.isEmpty else {
    log.info("No session name, skipping window lookup")
    return nil
  }

  guard AXIsProcessTrusted() else {
    log.warning("Accessibility not trusted — cannot enumerate windows")
    return nil
  }

  guard let ghostty = NSWorkspace.shared.runningApplications
    .first(where: { $0.bundleIdentifier == "com.mitchellh.ghostty" })
  else {
    log.warning("Ghostty not found in running applications")
    return nil
  }

  let appElement = AXUIElementCreateApplication(ghostty.processIdentifier)
  var windowsValue: CFTypeRef?
  guard
    AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsValue)
      == .success,
    let windows = windowsValue as? [AXUIElement]
  else {
    log.error("Failed to get AX windows from Ghostty")
    return nil
  }

  log.info("Found \(windows.count) Ghostty window(s), looking for session: \(session)")

  for window in windows {
    var titleValue: CFTypeRef?
    guard
      AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &titleValue) == .success,
      let title = titleValue as? String
    else {
      log.debug("Window has no title, skipping")
      continue
    }

    var windowID: UInt32 = 0
    let gotID = _AXUIElementGetWindow(window, &windowID) == .success
    log.info("  Window title: \"\(title)\" (id: \(gotID ? String(windowID) : "unknown"))")

    if title.localizedCaseInsensitiveContains(session) {
      guard gotID else {
        log.error("Matched window but failed to get CGWindowID")
        continue
      }
      log.info("Matched! Returning windowID \(windowID)")
      return windowID
    }
  }

  log.warning("No Ghostty window title contains session: \(session)")
  return nil
}

func focusZellijTab(session: String, tabName: String, paneId: String?) {
  guard let zellijPath = findZellijPath() else { return }

  let process = Process()
  process.executableURL = URL(fileURLWithPath: zellijPath)
  process.arguments = ["--session", session, "action", "go-to-tab-name", tabName]
  process.standardOutput = FileHandle.nullDevice
  process.standardError = FileHandle.nullDevice

  do {
    try process.run()
    process.waitUntilExit()
  } catch {
    return
  }

  if let paneId = paneId, !paneId.isEmpty {
    focusZellijPane(session: session, paneId: paneId)
  }
}

private func focusZellijPane(session: String, paneId: String) {
  guard let zellijPath = findZellijPath() else { return }

  let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
  let pluginPath = "file:\(homeDir)/.config/zellij/plugins/room.wasm"

  let process = Process()
  process.executableURL = URL(fileURLWithPath: zellijPath)
  process.arguments = [
    "--session", session,
    "pipe",
    "--plugin", pluginPath,
    "--name", "focus-pane",
    "--", paneId,
  ]
  process.standardOutput = FileHandle.nullDevice
  process.standardError = FileHandle.nullDevice

  try? process.run()
  process.waitUntilExit()
}
