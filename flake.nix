{
  description = "Smart macOS notifications for Claude Code in Ghostty + Zellij";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      forDarwin = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    in
    {
      packages = forDarwin (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          gitSHA = self.rev or "dirty";
        in
        {
          default = pkgs.stdenv.mkDerivation {
            pname = "claude-zellij-whip";
            version = self.shortRev or self.dirtyShortRev or "dev";
            src = self;

            nativeBuildInputs = [ pkgs.swift ];

            buildInputs = with pkgs.darwin.apple_sdk.frameworks; [
              AppKit
              ApplicationServices
            ];

            buildPhase = ''
              export HOME=$TMPDIR
              swift build -c release
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

              runHook postInstall
            '';

            meta = {
              description = "Smart macOS notifications for Claude Code in Ghostty + Zellij";
              platforms = nixpkgs.lib.platforms.darwin;
              license = nixpkgs.lib.licenses.mit;
            };
          };
        }
      );

    };
}
