class env::std::install_megacli {

  require env::std::install_hwraid_apt_source

  case "${::lsbdistcodename}" {
    'trixie' : {
      package {
        'megacli':
          ensure => installed,
          require  => [File['/etc/apt/sources.list.d/hwraid.list'], Exec['apt_update']]
      }
    }
    'buster', 'bullseye' : {
      package {
        'megacli':
          ensure => installed,
          require  => [Apt::Source['hwraid.le-vert.net'], Exec['apt_update']]
      }
    }
  }

}
