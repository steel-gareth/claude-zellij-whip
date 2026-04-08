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
    .executableTarget(
      name: "claude-zellij-whip",
      dependencies: ["PrivateAPI"],
      path: "Sources"
    ),
  ]
)
