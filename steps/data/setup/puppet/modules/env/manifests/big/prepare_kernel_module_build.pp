class env::big::prepare_kernel_module_build {

  # Prepare everything needed to build a custom kernel module.
  # Installs kernel headers for the latest available kernel, which can be different
  # from the running kernel.


  # debian13 env only
  # Provide linux-image packages from packages.grid5000.fr, built for full cgroup v1 support (Bug #18205)
  # Added in big recipe for nvidia modules building
  if $::lsbdistcodename == 'trixie' {
    env::common::g5kpackages {
      "linux-image":
        release  => "${::lsbdistcodename}",
        packages => ["linux-image-${env::deb_arch}", "linux-headers-${env::deb_arch}"],
        ensure   => installed;
    }

    package {
      ['module-assistant', 'dkms']:
        ensure    => installed,
        require   => [Env::Common::G5kpackages['linux-image'], Exec['apt_update']];
    }

  } else {

    package {
      ['module-assistant', 'dkms']:
        ensure    => installed;
    }

  }

  exec {
    'prepare_kernel_module_build':
      command   => "/usr/bin/m-a prepare -i -l ${installed_kernelreleases[-1]}",
      user      => root,
      require   => Package['module-assistant'];
  }

}
