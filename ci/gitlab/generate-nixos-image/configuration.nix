{
  pkgs,
  lib,
  config,
  modulesPath,
  inputs,
  ...
}: let
  version = "$GENERATED_ENV_VERSION";
  pipelineId = "$CI_PIPELINE_ID";
  commitShortSha = "$CI_COMMIT_SHORT_SHA";
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

  security.polkit.enable = true;

  security.sudo = {
    enable = true;
  };

  # Fix possible timeout on boot waiting for a TPM device
  boot.initrd.systemd.tpm2.enable = false;
  systemd.tpm2.enable = false;

  time.timeZone = "Europe/Paris";
  boot.loader = {
    systemd-boot.enable = true;
    # We need to change the boot order on rebuild otherwise we will keep using the initial config known by kadeploy
    #efi = {
    #  canTouchEfiVariables = true;
    #  efiSysMountPoint = "/boot/efi";
    #};
  };

  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/KDPL_DEPLOY_disk0";
    fsType = "ext4";
  };
  # We need to mount the EFI partition to be able to change the boot order on rebuild
  #fileSystems."/boot/efi" = {
  #  device = "/dev/disk/by-partlabel/efi";
  #  fsType = "vfat";
  #  options = ["fmask=0022" "dmask=0022"];
  #};

  # TODO: using networkmanager currently breaks ipv6?
  networking.useDHCP = true;

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

  # Fix the generated kadeploy env description
  system.build.kadeploy_env_description = pkgs.writeTextFile {
    name = "nixos2605-x64-min.dsc";
    text = ''
      name: nixos2605-min
      alias: nixos2605-x64-min
      arch: x86_64
      version: ${version}
      description: NixOS 26.05 for x86_64 - min
      author: support-staff@lists.grid5000.fr
      visibility: public
      destructive: false
      os: linux
      image:
        file: http://public.nancy.grid5000.fr/~ajenkins/environments/pipelines/${pipelineId}-${commitShortSha}/nixos2605-x64-min.tar.zst
        kind: tar
        compression: zstd
      postinstalls:
      - archive: server:///grid5000/postinstalls/g5k-postinstall.tgz
        compression: gzip
        script: g5k-postinstall --net none --disk-aliases
      boot:
        kernel: ${config.boot.kernelPackages.kernel}/${config.system.boot.loader.kernelFile}
        initrd: ${config.system.build.initialRamdisk}/${config.system.boot.loader.initrdFile}
        kernel_params: init=${config.system.build.toplevel}/init rw modprobe.blacklist=nouveau
      filesystem: ext4
      partition_type: 131
      multipart: false
    '';
  };

  # Fix the name of the generated files
  system.build.g5k-image = pkgs.stdenv.mkDerivation {
    name = "g5k-image";
    dontUnpack = true;
    doCheck = false;

    installPhase = ''
      mkdir $out

      ln -s ${config.system.build.kadeploy_env_description} $out/nixos2605-x64-min.dsc
      ln -s ${config.system.build.g5k-image-archive}/tarball/nixos2605-x64-min.tar.zst $out/nixos2605-x64-min.tar.zst
    '';
  };

  # Fix the compression to use zstd like other environments
  system.build.g5k-image-archive = import "${toString modulesPath}/../lib/make-system-tarball.nix" {
    fileName = "nixos2605-x64-min";
    stdenv = pkgs.stdenv;
    closureInfo = pkgs.closureInfo;
    pixz = pkgs.pixz;

    # ZSTD compression support
    compressCommand = "zstd -T0 --rm";
    compressionExtension = ".zst";
    extraInputs = [pkgs.zstd];

    extraCommands = pkgs.writeScript "extra-commands.sh" ''
      # Add necessary dirs for compatibility with g5k-postinstall and systemd boot
      mkdir -p boot root tmp var/log etc/nixos etc/NetworkManager/system-connections/ run

      # This provides /etc/os-release and other required files for kadeploy
      cp -a ${config.system.build.etc}/etc/. etc/
      chmod -R u+w etc/

      # For compatibility with g5k-postinstall, we need to be able to add udev rules and to modify the fstab
      rm etc/udev/rules.d etc/fstab
      cp -aL "${config.system.build.etc}/etc/udev/rules.d/." etc/udev/rules.d/
      cp -aL "${config.system.build.etc}/etc/fstab" etc/fstab
      chmod -R u+w etc/udev/rules.d/ etc/fstab

      # Allow easy nixos-rebuild of the current flake by having a writable copy in etc/nixos
      cp -r ${inputs.self}/{flake.nix,configuration.nix,flake.lock} etc/nixos/
      chmod -R u+w etc/nixos
    '';

    storeContents = [
      {
        object = config.system.build.toplevel;
        symlink = "/nix/var/nix/profiles/system";
      }
    ];

    contents = [
    ];
  };
}
