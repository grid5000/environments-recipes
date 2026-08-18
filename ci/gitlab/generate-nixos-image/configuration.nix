{
  pkgs,
  lib,
  ...
}: let
  version = "$GENERATED_ENV_VERSION";
  commitSha = "$CI_COMMIT_SHA";
in {
  environment.systemPackages = with pkgs; [
    busybox
    vim
    rsync
    gnupg
  ];

  system.stateVersion = "26.05";

  # Ensure compatibility with all clusters
  hardware.enableAllHardware = true;
  # For compatibility with RAID controller like on larochette
  boot.initrd.availableKernelModules = ["mpi3mr"];

  services.openssh = {
    enable = true;
  };

  # Fix possible timeout on boot waiting for a TPM device
  boot.initrd.systemd.tpm2.enable = false;
  systemd.tpm2.enable = false;

  time.timeZone = "Europe/Paris";
  boot.loader = {
    # Grub is required for kadeploy compatiblity and PXE boot
    grub = {
      enable = true;
      device = "nodev";
    };
    efi = {
      efiSysMountPoint = "/boot/efi";
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-partlabel/KDPL_DEPLOY_disk0";
      fsType = "ext4";
    };
    "/boot/efi" = {
      device = "/dev/disk/by-partlabel/efi";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };
  };

  # On initial deployment, kadeploy will write the kernel parameters to kadeploy-cmdline.txt
  boot.kernelParams = let
    cmdlineFile = ./kadeploy-cmdline.txt;
    rawParams = if builtins.pathExists cmdlineFile
                then builtins.readFile cmdlineFile
                else "";
    paramsList = lib.splitString " " (lib.trim rawParams);
    # Ignore empty parameters and the initial init= parameter
    isWantedParam = x: x != "" && !(lib.hasPrefix "init=" x);
  in
    builtins.filter isWantedParam paramsList;

  # TODO: using networkmanager currently breaks ipv6?
  networking.useDHCP = true;

  # Set the hostname with DHCP
  networking.hostName = "";
  networking.dhcpcd.setHostname = true;
  security.polkit.enable = true;

  environment.etc = {
    "grid5000/release".text = ''
      nixos2605-x64-min-${version}
      ${commitSha}
    '';
    "motd".text = ''
      nixos2605-x64-min-${version}
      (Image based on NixOS 26.05 for AMD64)
      Maintained by support-staff <support-staff@lists.grid5000.fr>
    '';
  };

  users.motdFile = "/etc/motd";
}
