// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "claude-zellij-whip",
  platforms: [.macOS(.v13)],
  targets: [
    .target(
      name: "PrivateAPI",
      path: "PrivateAPI"
    ),
    .target(
      name: "ClaudeZellijWhipCore",
      dependencies: ["PrivateAPI"],
      path: "Sources/ClaudeZellijWhipCore"
    ),
    .executableTarget(
      name: "claude-zellij-whip",
      dependencies: ["ClaudeZellijWhipCore"],
      path: "Sources/App"
    ),
    .testTarget(
      name: "ClaudeZellijWhipTests",
      dependencies: ["ClaudeZellijWhipCore"],
      path: "Tests/ClaudeZellijWhipTests"
    ),
  ]
)
