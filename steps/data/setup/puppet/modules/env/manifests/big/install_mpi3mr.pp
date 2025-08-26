# https://intranet.grid5000.fr/bugzilla/show_bug.cgi?id=17335

class env::big::install_mpi3mr {

  case $operatingsystem {
    'Debian': {
      case "${lsbdistcodename}" {
        "buster": {
          # Not relevant
        }
        'bullseye': {
          env::common::g5kpackages {
            'mpi3mr':
            notify  => Exec['dkms_last_kernel_update'];
          }
          exec {
            'dkms_last_kernel_update':
            command => "/usr/sbin/dkms autoinstall -k ${installed_kernelreleases[-1]}",
            notify  => Exec['generate_initramfs'],
            refreshonly => true;
          }
        }
        "bookworm" : {
          # Not needed (already provided by the kernel)
        }
        default: {
          fail "${lsbdistcodename} not supported."
        }
      }
    }
    default: {
      fail "${operatingsystem} not supported."
    }
  }
}
