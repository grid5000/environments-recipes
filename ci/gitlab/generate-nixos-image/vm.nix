{inputs, config, ...}: {
  virtualisation.vmVariant = {
    # Enable automatic login as root on the virtual console (TTY)
    services.getty.autologinUser = "root";
    # Enable SSH and allow root login with password
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = true;
      };
    };
    users.users.root.password = "g5k";

    # Forward host port 2222 to VM port 22
    virtualisation = {
      memorySize = 4096; # MiB
      cores = 4;
      # Disables the .qcow2 file; uses an in-memory tmpfs for root
      diskImage = null;

      forwardPorts = [
        {
          from = "host";
          host.port = 2222;
          guest.port = 22;
        }
      ];
      additionalPaths = [
        config.system.build.toplevel
      ];
    };

    # Allows rebuild of this flake in the VM
    boot.postBootCommands = ''
      cp -rf ${inputs.self}/. /etc/nixos/
      chmod -R u+w /etc/nixos
    '';
  };
}
