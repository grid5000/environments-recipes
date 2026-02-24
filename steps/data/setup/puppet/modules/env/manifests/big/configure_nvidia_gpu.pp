class env::big::configure_nvidia_gpu () {

  # Blacklist nvidia modules
  include 'env::big::configure_nvidia_gpu::modules'

  # Install nvidia drivers
  include 'env::big::configure_nvidia_gpu::drivers'

  # Install additional services (currently nvidia-smi, needed by cuda and prometheus)
  include 'env::big::configure_nvidia_gpu::services'

  # Install fabricmanager (needed by cluster with nvswitch technology)
  if $env::deb_arch == 'amd64' {
    if ($::env::common::software_versions::nvidia_fabricmanager) {
      include 'env::big::configure_nvidia_gpu::fabricmanager_deb'
    } else {
      # x86_64 460.91.03 -> buster
      include 'env::big::configure_nvidia_gpu::fabricmanager'
    }
  }

  # CUDA no more installed since Debian 13 Trixie (bugs #15653 and #14466) : module usage
  if $::lsbdistcodename != 'trixie' {
    # Install cuda
    include 'env::big::configure_nvidia_gpu::cuda'
  }

  # Install nvidia prometheus exporter
  include 'env::big::configure_nvidia_gpu::prometheus'
}
