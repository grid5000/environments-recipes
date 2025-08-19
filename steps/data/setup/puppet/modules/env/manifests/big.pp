# This file contains the 'big' class used to configure improved environment to be executed in grid'5000.
class env::big ( $variant = 'big', $parent_parameters = {} ){

  $big_parameters = {
    mic_enable => false
  }
  $parameters = stdlib::merge( $big_parameters, $parent_parameters )

  # Include nfs class
  class {
    'env::nfs':
      variant           => $variant,
      parent_parameters => $parameters;
  }
  # mail
  class { 'env::big::configure_postfix': }
  # kvm
  class { 'env::big::configure_kvm': }
  # nvidia
  if $env::deb_arch == 'amd64' or $env::deb_arch == 'ppc64el' {
    class { 'env::big::configure_nvidia_gpu': }
  }
  # amdgpu
  if $env::deb_arch == 'amd64' {
    class { 'env::big::configure_amd_gpu': }
  }
  # beegfs install
  if $env::deb_arch == 'amd64' {
    class { 'env::big::install_beegfs': }
  }
  # singularity install
  if $env::deb_arch == 'amd64' {
    class { 'env::big::install_singularity': }
  }
  #Allow sshfs
  class { 'env::big::configure_sshfs': }
  # Config OpenMPI
  class { 'env::big::install_openmpi': }
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
  class { 'env::big::install_mpi3mr': }

}
