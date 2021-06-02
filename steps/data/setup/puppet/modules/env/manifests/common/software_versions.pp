# This file defines the software versions in use

class env::common::software_versions {
   $g5k_subnets = '1.4.2'
   $g5k_meta_packages = '0.7.45'
   $tgz_g5k = '2.0.17'
   $g5k_checks = '0.11.0'
   $sudo_g5k = '1.11'
   $ganglia_monitor = '3.6.0-7.1'
   $libguestfs_backport_arm64 = '1:1.40.2-7~bpog5k10+1'
   $libguestfs_backport_ppc64el = '1:1.40.2-7~bpog5k10+1'
   $lmod = '6.6-0.3g5k1'
   $datacenter_gpu_manager = '1:1.7.2'
   $dcgm_exporter = '2.0.0-rc.11'
   $g5k_jupyterlab = '0.6'

  case $lsbdistcodename {
    'bullseye': {
      $datacenter_gpu_manager = '1:2.1.4'
    }
    default: {
      $datacenter_gpu_manager = '1:1.7.2'
    }

  }
}
