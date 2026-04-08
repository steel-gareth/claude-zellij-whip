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
          default = pkgs.callPackage ./nix/package.nix {
            src = self;
            inherit gitSHA;
          };
        }
      );
    };
}
