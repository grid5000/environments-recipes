class env::min::kernel::remove_old {
  # Remove the current kernel if it's not the last one
  if $kernelrelease != $installed_kernelreleases[-1] {
    package { "linux-image-$kernelrelease":
      ensure => 'purged'
    }

    file {
      "/lib/modules/$kernelrelease":
        ensure => absent,
        force  => true;
      "/usr/lib/modules/$kernelrelease":
        ensure => absent,
        force  => true;
    }
  }

  # Useful to know if the g5k kernel is installed in debian13 big and std variant
  exec {
    'display-installed-kernels':
      command  => '/usr/bin/uname -rv; /usr/bin/dpkg -l | /usr/bin/grep -E "ii  linux-(image|headers)"',
      logoutput => true;
  }
}
