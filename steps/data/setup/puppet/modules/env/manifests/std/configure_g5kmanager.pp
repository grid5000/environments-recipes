class env::std::configure_g5kmanager {
  case $operatingsystem {
    'Debian': {
      case "${::lsbdistcodename}" {
        "buster", "bullseye" : {
          file {
            '/usr/local/libexec/':
              ensure   => directory,
              mode     => '0755',
              owner    => 'root',
              group    => 'root';
            '/usr/local/lib/g5k/':
              ensure   => directory,
              mode     => '0755',
              owner    => 'root',
              group    => 'root';
            '/usr/local/lib/g5k/g5k-manager.rb':
              source => 'puppet:///modules/env/std/g5k-manager/lib/g5k-manager.rb',
              mode   => '0755',
              ensure => file;
          }
        }
        default : {
          fail "${::lsbdistcodename} not supported."
        }
      }
    }
    default : {
      fail "${operatingsystem} not supported."
    }
  }
}

