class env::min::kernel::remove_old {
  # Remove the current kernel if it's not the last one
  if $facts['kernelrelease'] != $facts['installed_kernelreleases'][-1] {
    package { "linux-image-$facts['kernelrelease']":
      ensure => 'purged'
    }

    file {
      "/lib/modules/$facts['kernelrelease']":
        ensure => absent,
        force  => true;
      "/usr/lib/modules/$facts['kernelrelease']":
        ensure => absent,
        force  => true;
    }
  }
}
