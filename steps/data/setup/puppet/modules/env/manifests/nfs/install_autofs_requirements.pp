class env::nfs::install_autofs_requirements(){

  case "${::lsbdistcodename}" {
    'buster', 'trixie': {
      package {
        'autofs':
          ensure => installed;
      }
    }
    "bullseye", "bookworm" : {
      env::common::g5kpackages {
        'autofs-g5k':
          # see bug 13638
          ensure => '5.1.2-4',
          packages => ['autofs'],
          release => $::lsbdistcodename;
      }
    }
    default : {
      fail "${::lsbdistcodename} not supported."
    }
  }

  if Integer($facts['os']['release']['major']) >= 13 {
    augeas { '/files/etc/autofs.conf/negative_timeout':
      require => Package['autofs'],
      lens    => 'Ini.lns',
      value   => '0',
    }
    augeas { '/files/etc/autofs.conf/positive_timeout':
      require => Package['autofs'],
      lens    => 'Ini.lns',
      value   => '0',
    }
  }

  service {
    'autofs':
      ensure => running,
      require => Package['autofs'];
  }
}
