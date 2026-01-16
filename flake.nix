{
  description = "Mail server monitoring tool with ntfy.sh notifications";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      # Packages for each system
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          mail-monitor = pkgs.callPackage ./package.nix { };
          default = self.packages.${system}.mail-monitor;
        });

      # Apps for each system
      apps = forAllSystems (system: {
        mail-monitor = {
          type = "app";
          program = "${self.packages.${system}.mail-monitor}/bin/mail-monitor";
        };
        default = self.apps.${system}.mail-monitor;
      });

      # NixOS module
      nixosModules = {
        default = import ./module.nix;
        mail-monitor = import ./module.nix;
      };
    };
}
