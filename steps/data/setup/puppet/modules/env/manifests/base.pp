# This file contains the 'base' class used to configure a basic environment to be executed in grid'5000.

class env::base ( $variant = 'base', $parent_parameters = {} ){

  $base_parameters = {
    misc_keep_tmp => true,
  }

  $parameters = merge ( $base_parameters, $parent_parameters )
  # Include min class
  class {
    'env::min':
      variant           => $variant,
      parent_parameters => $parameters;
  }

  class { 'env::base::do_not_clean_tmp':
    keep_tmp => $parameters['misc_keep_tmp'];
  }

  # Include kexec-tools
  class { 'env::base::configure_kexec': }
  # SSH modification
  class { 'env::base::increase_ssh_maxstartups': }
  # Specific tuning
  class { 'env::base::tcp_tuning_for_10gbe': }
  # Cpufreq. Not available on ppc64
  # FIXME cpufreq not available in trixie (bug #17453)
  if ($env::deb_arch != 'ppc64el' and $facts[os][distro][codename] != 'trixie') {
    class { 'env::base::enable_cpufreq_with_performance_governor': }
  }
  #IbOverIP
  class { 'env::base::configure_ip_over_infiniband': }
  # memlock tuning for infiniband
  class { 'env::base::unlimited_memlock_for_infiniband': }
  # Omni-Path
  class { 'env::base::configure_omnipath': }
  #Add ca2019.grid5000.fr certificate
  class { 'env::base::add_ca_grid5000': }
  #Dhclient conf
  # FIXME not using dhclient by default in trixie (bug #17449)
  if ($facts[os][distro][codename] != 'trixie') {
    class { 'env::base::configure_dhclient': }
  }
  # Disable ndctl monitor service
  class { 'env::base::disable_ndctl_monitor': }
  # Enable userns for Nix
  class { 'env::base::enable_userns': }
  # Disable NVMe multipath support
  class { 'env::base::disable_nvme_multipath': }
}
