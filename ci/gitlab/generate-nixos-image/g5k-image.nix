{
  pkgs,
  config,
  modulesPath,
  inputs,
  ...
}: let
  version = "$GENERATED_ENV_VERSION";
  pipelineId = "$CI_PIPELINE_ID";
  commitShortSha = "$CI_COMMIT_SHORT_SHA";
in {
  imports = [
    ./configuration.nix
  ];

  # Add build dependencies (required to rebuild some packages) to allows offline rebuilds on deployment
  # The simplest way to understand what packages to put below is to run (after a config change)
  # `nixos-rebuild --flake /etc/nixos#default dry-run` and to look below the output `these X paths will be fetched`
  system.extraDependencies = with pkgs;
    [
      # Build environments & interpreters
      stdenvNoCC
      lndir # for pkgs.linkFarm

      # Wrapper hooks & helpers
      dieHook
      makeWrapper
      makeBinaryWrapper
      makeShellWrapper

      # Tools & headers needed to assemble system-path and service units
      desktop-file-utils
      texinfo
      getconf
      jq.dev
      kmod.dev
      libxslt.dev
    ]
    # Transient build-time derivations (e.g. check-sshd-config, initrd udev rules)
    ++ config.system.checks
    ++ config.boot.initrd.services.udev.packages;

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
        script: g5k-postinstall --net nixos --disk-aliases
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
      # Add necessary dirs for compatibility with g5k-postinstall to set the ssh host keys before the first boot and for network connections
      mkdir -p etc/ssh etc/NetworkManager/system-connections

      # Pre-populate the Nix SQLite database (Necessary to avoid problematic overwrites of existing packages on nixos-rebuild)
      export NIX_STATE_DIR="$(pwd)/nix/var/nix"
      export NIX_CONF_DIR="$(pwd)/etc/nix"

      mkdir -p $NIX_STATE_DIR/db
      ${config.nix.package.out}/bin/nix-store --load-db < nix-path-registration
      rm nix-path-registration

      # Allow easy nixos-rebuild of the current flake by having a writable copy in etc/nixos
      mkdir -p etc/nixos
      cp -r ${inputs.self}/{flake.nix,g5k-image.nix,configuration.nix,flake.lock,fstab-parser.nix} etc/nixos/
      chmod -R u+w etc/nixos
    '';

    storeContents = [
      {
        object = config.system.build.toplevel;
        # Must be symlinked here since we rely on /nix/var/nix/profiles/system/activate during GRUB installation
        symlink = "/nix/var/nix/profiles/system";
      }
    ];

    contents = [
    ];
  };
}
