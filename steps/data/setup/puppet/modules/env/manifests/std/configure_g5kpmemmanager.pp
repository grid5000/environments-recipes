class env::std::configure_g5kpmemmanager {

  require env::std::configure_g5kmanager

  case $facts[os][name] {
    'Debian': {
      case $facts[os][distro][codename] {
        'buster', 'bullseye' : {
          file {
            '/etc/systemd/system/g5k-pmem-manager.service':
              ensure => file,
              source => 'puppet:///modules/env/std/g5k-manager/g5k-pmem-manager.service';
            '/usr/local/libexec/g5k-pmem-manager':
              ensure => file,
              mode   => '0755',
              source => 'puppet:///modules/env/std/g5k-manager/g5k-pmem-manager';
            '/etc/systemd/system/multi-user.target.wants/g5k-pmem-manager.service':
              ensure => link,
              target => '/etc/systemd/system/g5k-pmem-manager.service';
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

