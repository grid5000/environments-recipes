class env::std::install_libguestfs_backport {

  case $facts[os][distro][codename] {
    'buster': {
      if $env::deb_arch == 'arm64' {
        env::common::g5kpackages {
          'libguestfs-backport':
            packages => 'libguestfs-tools',
            ensure  => $::env::common::software_versions::libguestfs_backport_arm64;
        }
      }
      elsif $env::deb_arch == 'ppc64el' {
        env::common::g5kpackages {
          'libguestfs-backport':
            packages => 'libguestfs-tools',
            ensure  => $::env::common::software_versions::libguestfs_backport_ppc64el;
        }
      }
      else {
        fail "${env::deb_arch} not supported"
      }
    }
    'bullseye': {
      # NOTHING
    }
    default: {
      fail "${facts[os][distro][codename]} not supported."
    }
  }
}
