{ lib, stdenvNoCC, src, gitSHA ? "unknown" }:

stdenvNoCC.mkDerivation {
  pname = "claude-zellij-whip";
  version = "unstable";

  inherit src;

  # nixpkgs ships Swift 5.10 but this project requires Swift 6.0;
  # use the system toolchain (Xcode / CommandLineTools) instead.
  # Zellij is discovered at runtime via nix-profile paths (see ZellijContext.swift)
  # so no build-time dependency on the zellij package is needed.

  buildPhase = ''
    runHook preBuild
    export HOME=$(mktemp -d)
    /usr/bin/swift build -c release --disable-sandbox
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    APP=$out/Applications/ClaudeZellijWhip.app
    mkdir -p $APP/Contents/{MacOS,Resources}
    cp .build/release/claude-zellij-whip $APP/Contents/MacOS/
    cp Resources/Info.plist $APP/Contents/
    cp Resources/AppIcon.icns $APP/Contents/Resources/

    VERSION=$(grep 'appVersion' Sources/ClaudeZellijWhipCore/Version.swift | sed 's/.*"\(.*\)".*/\1/')
    BUILD=$(grep 'buildNumber' Sources/ClaudeZellijWhipCore/Version.swift | sed 's/.*= //' | tr -d ' ')

    /usr/libexec/PlistBuddy -c "Add :GitCommitSHA string ${gitSHA}" $APP/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" $APP/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD" $APP/Contents/Info.plist

    /usr/bin/codesign --force --sign - $APP

    mkdir -p $out/bin
    cat > $out/bin/claude-zellij-whip <<EOF
#!/bin/sh
exec open "$out/Applications/ClaudeZellijWhip.app" --args "\$@"
EOF
    chmod +x $out/bin/claude-zellij-whip

    runHook postInstall
  '';

  meta = {
    description = "Native macOS notifications for Claude Code in Zellij/Ghostty";
    homepage = "https://github.com/steel-gareth/claude-zellij-whip";
    platforms = lib.platforms.darwin;
    license = lib.licenses.mit;
    mainProgram = "claude-zellij-whip";
  };
}
