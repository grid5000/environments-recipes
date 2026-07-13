# Based on the minimal template from https://github.com/oar-team/nixos-g5k-image/tree/master/templates/minimal
{
  description = "Default NixOS image for Grid'5000 Testbed";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = {nixpkgs, ...} @ inputs: let
    system = "x86_64-linux";

    g5kImageConfig = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs;};
      modules = [
        ./g5k-image.nix
      ];
    };
  in {
    packages.${system} = rec {
      g5k-image = g5kImageConfig.config.system.build.g5k-image;
      default = g5k-image;
    };

    # Rebuild with `nixos-rebuild --flake /etc/nixos#default switch`
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs;};
      modules = [
        ./configuration.nix
      ];
    };
  };
}
