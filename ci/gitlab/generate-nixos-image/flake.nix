# Based on the minimal template from https://github.com/oar-team/nixos-g5k-image/tree/master/templates/minimal
{
  description = "Default NixOS image for Grid'5000 Testbed";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-g5k-image = {
      url = "github:oar-team/nixos-g5k-image";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixos-g5k-image,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    nixosConfig = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs;};

      modules = [
        nixos-g5k-image.nixosModules.g5k-image-systemd
        ./configuration.nix
      ];
    };
  in {
    packages.${system} = rec {
      g5k-image = nixosConfig.config.system.build.g5k-image;
      default = g5k-image;
    };

    # Rebuild with `nixos-rebuild --flake /etc/nixos#default switch`
    nixosConfigurations.default = nixosConfig;
  };
}
