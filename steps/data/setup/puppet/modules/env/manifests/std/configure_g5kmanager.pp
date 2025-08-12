class env::std::configure_g5kmanager {
  case $facts[os][name] {
    'Debian': {
      case $facts[os][distro][codename] {
        'buster', 'bullseye' : {
          file {
            '/usr/local/libexec/':
              ensure => directory,
              mode   => '0755',
              owner  => 'root',
              group  => 'root';
            '/usr/local/lib/g5k/':
              ensure => directory,
              mode   => '0755',
              owner  => 'root',
              group  => 'root';
            '/usr/local/lib/g5k/g5k-manager.rb':
              ensure => file,
              mode   => '0755',
              source => 'puppet:///modules/env/std/g5k-manager/lib/g5k-manager.rb';
          }
        }
        default : {
          fail "${facts[os][distro][codename]} not supported."
        }
      }
    }
    default : {
      fail "${facts[os][name]} not supported."
    }
  }
}

