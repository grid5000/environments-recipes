class env::big::configure_nvidia_gpu::drivers () {

  ### This class exists for gpuclus cluster, that require a recent version of nvidia driver

  include env::big::prepare_kernel_module_build

  case "$env::deb_arch" {
    "amd64": {
      $driver_source = 'http://packages.grid5000.fr/other/nvidia/NVIDIA-Linux-x86_64-450.80.02.run'
    }
    "ppc64el": {
      # Newer version of the driver (440.X, 450.X) are unstable and cause kernel panic.
      # See https://intranet.grid5000.fr/bugzilla/show_bug.cgi?id=12545
      $driver_source = 'http://packages.grid5000.fr/other/nvidia/NVIDIA-Linux-ppc64le-418.165.02.run'
    }
    default: {
      err "${env::deb_arch} not supported"
    }
  }

  # The nvidia installer fails because it tries to load the module 'nvidia-drm' at the end.
  # This cannot work because we don't have any GPU on the build host (it's a VM).
  # We temporarily blacklist the module and force the modprobe call to take it into account
  # (using the MODPROBE_OPTIONS env variable to pass "-b").
  file{
    '/etc/modprobe.d/blacklist-nvidia.conf':
      ensure    => file,
      content   => "blacklist nvidia-drm\ninstall nvidia-drm /bin/true\n",
      before    => Exec['install_nvidia_driver'];
  }
  # Cleanup blacklist after the installer has run, we don't want it in the final image.
  file{
    '/etc/modprobe.d/blacklist-nvidia.conf':
      ensure    => absent,
      require   => Exec['install_nvidia_driver'];
  }
  exec{
    'retrieve_nvidia_drivers':
      command   => "/usr/bin/wget -q $driver_source -O /tmp/NVIDIA-Linux.run; chmod u+x /tmp/NVIDIA-Linux.run",
      timeout   => 1200, # 20 min
      creates   => "/tmp/NVIDIA-Linux.run";
    'install_nvidia_driver':
      command   => "/tmp/NVIDIA-Linux.run -qa --no-cc-version-check --ui=none --dkms -k ${installed_kernelreleases[-1]}",
      timeout   => 1200, # 20 min,
      user      => root,
      environment => ['MODPROBE_OPTIONS=-b'],
      require   => [Exec['prepare_kernel_module_build'], File['/tmp/NVIDIA-Linux.run']];
    'cleanup_nvidia':
      command   => "/bin/rm /tmp/NVIDIA-Linux.run",
      user      => root,
      require   => Exec['install_nvidia_driver'];
  }
  file{
    '/tmp/NVIDIA-Linux.run':
      ensure    => file,
      require   => Exec['retrieve_nvidia_drivers'];
  }
}
