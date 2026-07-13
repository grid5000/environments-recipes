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
    # TODO: compare installed packages with other min images
  ];

  system.stateVersion = "26.05";

  # Ensure compatibility with all clusters
  hardware.enableAllHardware = true;

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

  # The first boot will use a simplified grub.cfg generated from the minios with the correct kernel parameters
  # For subsequent boots, we need to copy these parameters before generating our own grub.cfg
  systemd.services.save-kadeploy-cmdline = {
    description = "Save Kadeploy kernel parameters for subsequent nixos-rebuilds";
    wantedBy = ["multi-user.target"];

    unitConfig = {
      # Run only if the file hasn't been created yet
      ConditionPathExists = "!/etc/nixos/kadeploy-cmdline.txt";
    };

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      read -r cmdline < /proc/cmdline
      filtered_params=()

      for param in $cmdline; do
        case "$param" in
          # Filter out params managed by NixOS bootloader or kadeploy's deployment process
          init=*|root=*|rw)
            ;;
          *)
            filtered_params+=("$param")
            ;;
        esac
      done

      # Write the filtered parameters space-separated to the nixos folder
      echo -n "''${filtered_params[*]}" > /etc/nixos/kadeploy-cmdline.txt
    '';
  };

  boot.kernelParams = let
    cmdlineFile = ./kadeploy-cmdline.txt;
  in
    if builtins.pathExists cmdlineFile
    then builtins.filter (x: x != "") (lib.splitString " " (lib.trim (builtins.readFile cmdlineFile)))
    else [];

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
