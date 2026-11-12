# Based on the minimal template from https://github.com/oar-team/nixos-g5k-image/tree/master/templates/minimal
{
  description = "Default NixOS image for Grid'5000 Testbed";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = {nixpkgs, ...} @ inputs: let
    supportedSystems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    packages = forAllSystems (system: let
      g5kImageConfig = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          ./g5k-image.nix
          ./vm.nix
        ];
      };
    in {
      g5k-image = g5kImageConfig.config.system.build.g5k-image;
      # You can test quickly in a VM with `nix run .#vm`
      # It allows SSH login on localhost port 2222 as root with password "g5k"
      vm = g5kImageConfig.config.system.build.vm;
    });

    # Rebuild with `nixos-rebuild --flake /etc/nixos#default switch`
    # Nix CLI automatically resolves `legacyPackages.${currentSystem}.nixosConfigurations.default`
    # This allows #default to works for any system architecture
    legacyPackages = forAllSystems (system: {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          ./configuration.nix
        ];
      };
    });
  };
}
