# https://intranet.grid5000.fr/bugzilla/show_bug.cgi?id=17335

class env::big::install_mpi3mr {

  case $facts[os][name] {
    'Debian': {
      case "${facts[os][distro][codename]}" {
        'bullseye': {
          env::common::g5kpackages {
            'mpi3mr':
            notify  => Exec['dkms_last_kernel_update'];
          }
          exec {
            'dkms_last_kernel_update':
            command => "/usr/sbin/dkms autoinstall -k ${facts[installed_kernelreleases][-1]}",
            notify  => Exec['generate_initramfs'],
            refreshonly => true;
          }
        }
        "bookworm" : {
          # Not needed (already provided by the kernel)
        }
        default: {
          fail "${facts[os][distro][codename]} not supported."
        }
      }
    }
    default: {
      fail "$facts[os][name] not supported."
    }
  }
}
