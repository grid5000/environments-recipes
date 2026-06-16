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
  environment.systemPackages = with pkgs; [vim];

  system.stateVersion = "26.05";

  # Fix possible timeout on boot waiting for a TPM device
  systemd.tpm2.enable = false;

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

  # Fix the generated kadeploy env description
  system.build.kadeploy_env_description = lib.mkForce (pkgs.writeTextFile {
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
        script: g5k-postinstall --net none,predictable_kernel_name,traditional-names --bootloader no-grub-from-deployed-env
      boot:
        kernel: /boot/bzImage
        initrd: /boot/initrd
        kernel_params: init=boot/init modprobe.blacklist=nouveau
      filesystem: ext4
      partition_type: 131
      multipart: false
    '';
  });

  # Fix the name of the generated files
  system.build.g5k-image = lib.mkForce (pkgs.stdenv.mkDerivation {
    name = "g5k-image";
    dontUnpack = true;
    doCheck = false;

    installPhase = ''
      mkdir $out

      ln -s ${config.system.build.kadeploy_env_description} $out/nixos2605-x64-min.dsc
      ln -s ${config.system.build.g5k-image-archive}/tarball/nixos2605-x64-min.tar.zst $out/nixos2605-x64-min.tar.zst
    '';
  });

  # Fix the compression to use zstd like other environments
  system.build.g5k-image-archive = lib.mkForce (import "${toString modulesPath}/../lib/make-system-tarball.nix" {
    fileName = "nixos2605-x64-min";
    stdenv = pkgs.stdenv;
    closureInfo = pkgs.closureInfo;
    pixz = pkgs.pixz;

    # ZSTD compression support
    compressCommand = "zstd -T0 --rm";
    compressionExtension = ".zst";
    extraInputs = [pkgs.zstd];

    extraCommands = pkgs.writeScript "extra-commands.sh" ''
      mkdir -p etc/ssh root tmp var/log etc/nixos

      # Allow easy nixos-rebuild of the current flake by having a writable copy in etc/nixos
      cp -r ${inputs.self}/{flake.nix,configuration.nix,flake.lock} etc/nixos/
      chmod -R u+w etc/nixos
    '';
    storeContents = [
      {
        object = config.system.build.toplevel;
        symlink = "/run/current-system";
      }
    ];

    contents = [
      {
        source = config.system.build.initialRamdisk + "/" + config.system.boot.loader.initrdFile;
        target = "/boot/" + config.system.boot.loader.initrdFile;
      }
      {
        source = config.boot.kernelPackages.kernel + "/" + config.system.boot.loader.kernelFile;
        target = "/boot/" + config.system.boot.loader.kernelFile;
      }
      {
        source = "${builtins.unsafeDiscardStringContext config.system.build.toplevel}/init";
        target = "/boot/init";
      }
    ];
  });
}
