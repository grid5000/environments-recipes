# This file contains the 'big' class used to configure improved environment to be executed in grid'5000.
class env::big ( $variant = "big", $parent_parameters = {} ){

  $big_parameters = {
    mic_enable => false
  }
  $parameters = merge( $big_parameters, $parent_parameters )

  # Include nfs class
  class {
    'env::nfs':
      variant => $variant,
      parent_parameters => $parameters;
  }
  # mail
  class { 'env::big::configure_postfix': }
  # kvm
  class { 'env::big::configure_kvm': }
  # NVIDIA
  # GPU kernel module only for Debian 13 Trixie (bugs #15653 and #14466)
  if $env::deb_arch == 'amd64' or $env::deb_arch == 'ppc64el' or ($env::deb_arch == 'arm64' and $::lsbdistcodename == 'trixie') {
    class { 'env::big::configure_nvidia_gpu': }
  }
  # AMD
  if $env::deb_arch == 'amd64' {
    class { 'env::big::configure_amd_gpu': }
    # GPU kernel module only for Debian 13 Trixie (bugs #15653 and #14466)
    # but still needs rocm-smi (bug #18590)
    if $::lsbdistcodename == 'trixie' {
      # install rocm-smi only
      class { 'env::big::install_rocm_smi': }
    } else {
      # install rocm
      class { 'env::big::configure_rocm': }
    }
  }
  # beegfs install
  if $env::deb_arch == 'amd64' {
    class { 'env::big::install_beegfs': }
  }
  # singularity install
  if $env::deb_arch == 'amd64' {
    class { 'env::big::install_singularity': }
  }
  # Allow sshfs
  class { 'env::big::configure_sshfs': }
  # OpenMPI install and config
  # provided by module(s) for Debian 13 Trixie (bug #17590)
  if $::lsbdistcodename != 'trixie' {
    class { 'env::big::install_openmpi': }
  }
  # Snmp tools
  class { 'env::big::install_snmp_tools': }
  # remove RESUME device from initramfs
  class { 'env::big::configure_initramfs': }
  # Prometheus
  class { 'env::big::install_prometheus_exporters': }
  # g5k-jupyterlab
  class { 'env::big::install_g5k_jupyterlab': }
  # smartd
  class { 'env::big::install_smartd': }
  # disable unattended-upgrades
  class { 'env::big::disable_unattended_upgrades': }
  # Mpi3mr
  if $env::deb_arch == 'amd64' {
    class { 'env::big::install_mpi3mr': }
  }

}
