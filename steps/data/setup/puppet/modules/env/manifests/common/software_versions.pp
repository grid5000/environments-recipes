# This file defines the software versions in use

class env::common::software_versions {
  $g5k_subnets                 = '1.4.2'
  $g5k_meta_packages           = '0.7.46'
  $tgz_g5k                     = '2.0.17'
  $g5k_checks                  = '0.11.2'
  $sudo_g5k                    = '1.11'
  $ganglia_monitor             = '3.6.0-7.1'
  $libguestfs_backport_arm64   = '1:1.40.2-7~bpog5k10+1'
  $libguestfs_backport_ppc64el = '1:1.40.2-7~bpog5k10+1'
  $lmod                        = '6.6-0.3g5k1'
  $g5k_jupyterlab              = '0.6'
  $rocm_version                = '4.3.1'

  case "$env::deb_arch" {
    'amd64': {
      $nvidia_driver_arch         = 'x86_64'
      case $lsbdistcodename {
        'stretch', 'buster': {
          $nvidia_driver          = '450.119.04'
          $nvidia_cuda            = '10.1.243_418.87.00_linux'
          $datacenter_gpu_manager = '1:1.7.2'
          $dcgm_exporter          = '2.0.0-rc.11'
        }
        'bullseye': {
          $nvidia_driver          = '460.91.03'
          $nvidia_cuda            = '11.2.2_460.32.03_linux'
          $datacenter_gpu_manager = '1:2.1.4'
          $dcgm_exporter          = '2.3.0-1'
        }
      }
    }
    'ppc64el': {
      # We are stuck on driver 418 for ppc64.
      # Newer version of the driver (440.X, 450.X, 460.X) are unstable and cause kernel panic.
      # See https://intranet.grid5000.fr/bugzilla/show_bug.cgi?id=12545
      $nvidia_driver_arch         = 'ppc64le'
      case $lsbdistcodename {
        'stretch', 'buster': {
          $nvidia_driver          = '418.197.02'
          $nvidia_cuda            = '10.1.243_418.87.00_linux_ppc64le'
          $datacenter_gpu_manager = '1:1.7.2'
          $dcgm_exporter          = '2.0.0-rc.11'
        }
        'bullseye': {
          $nvidia_driver          = '418.197.02'
          $nvidia_user_driver     = '460.91.03'
          $nvidia_cuda            = '11.2.2_460.32.03_linux_ppc64le'
          $datacenter_gpu_manager = '1:2.0.15'
          $dcgm_exporter          = '2.3.0-1'
        }
      }
    }
  }
}
