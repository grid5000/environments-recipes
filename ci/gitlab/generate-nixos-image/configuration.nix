{ pkgs, lib, config, ... }:
let
  version = "$GENERATED_ENV_VERSION";
  pipelineId = "$CI_PIPELINE_ID";
  commitSha = "$CI_COMMIT_SHORT_SHA";
in
{
  environment.systemPackages = with pkgs; [ vim ];

  system.stateVersion = "26.05";

  # Fix possible timeout on boot waiting for a TPM device
  systemd.tpm2.enable = false;

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
        file: http://public.nancy.grid5000.fr/~ajenkins/environments/pipelines/${pipelineId}-${commitSha}/nixos2605-x64-min.tar.xz
        kind: tar
        compression: xz
      postinstalls:
      - archive: server:///grid5000/postinstalls/g5k-postinstall.tgz
        compression: gzip
        script: g5k-postinstall --net none,predictable_kernel_name,traditional-names --bootloader no-grub-from-deployed-env
      boot:
        kernel: /boot/bzImage
        initrd: /boot/initrd
        kernel_params: init=boot/init console=tty0 console=ttyS0,115200
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
      ln -s ${config.system.build.g5k-image-archive}/tarball/*.tar.xz $out/nixos2605-x64-min.tar.xz
    '';
  });
}
