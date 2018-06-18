class env::base::packages () {

  $installed = [
    'bind9-host',
    'bzip2',
    'curl',
    'ipython',
    'python',
    'rsync',
    'ruby',
    'taktuk',
    'vim',
  ]

  package {
    $installed:
      ensure => installed;
  }
}
