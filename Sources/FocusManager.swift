import AppKit
import ApplicationServices
import PrivateAPI

func focusGhostty(windowID: UInt32? = nil) {
  guard let ghostty = NSWorkspace.shared.runningApplications
    .first(where: { $0.bundleIdentifier == "com.mitchellh.ghostty" })
  else { return }

  if let windowID = windowID,
    raiseGhosttyWindow(pid: ghostty.processIdentifier, windowID: windowID)
  {
    ghostty.activate(options: [.activateIgnoringOtherApps])
  } else {
    ghostty.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
  }
}

private func raiseGhosttyWindow(pid: pid_t, windowID: UInt32) -> Bool {
  guard AXIsProcessTrusted() else { return false }

  let appElement = AXUIElementCreateApplication(pid)
  var windowsValue: CFTypeRef?
  guard
    AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsValue)
      == .success,
    let windows = windowsValue as? [AXUIElement]
  else { return false }

  for window in windows {
    var axWindowID: UInt32 = 0
    guard _AXUIElementGetWindow(window, &axWindowID) == .success else { continue }
    if axWindowID == windowID {
      AXUIElementPerformAction(window, kAXRaiseAction as CFString)
      return true
    }
  }

  return false
}

func findGhosttyWindowID(session: String?) -> UInt32? {
  guard let session = session, !session.isEmpty else { return nil }
  guard AXIsProcessTrusted() else { return nil }

  guard let ghostty = NSWorkspace.shared.runningApplications
    .first(where: { $0.bundleIdentifier == "com.mitchellh.ghostty" })
  else { return nil }

  let appElement = AXUIElementCreateApplication(ghostty.processIdentifier)
  var windowsValue: CFTypeRef?
  guard
    AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsValue)
      == .success,
    let windows = windowsValue as? [AXUIElement]
  else { return nil }

  for window in windows {
    var titleValue: CFTypeRef?
    guard
      AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &titleValue) == .success,
      let title = titleValue as? String
    else { continue }

    if title.localizedCaseInsensitiveContains(session) {
      var windowID: UInt32 = 0
      guard _AXUIElementGetWindow(window, &windowID) == .success else { continue }
      return windowID
    }
  }

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
