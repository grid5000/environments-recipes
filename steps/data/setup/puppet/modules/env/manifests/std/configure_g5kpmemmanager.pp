class env::std::configure_g5kpmemmanager {

  require env::std::configure_g5kmanager

  case $facts[os][name] {
    'Debian': {
      case "${facts[os][distro][codename]}" {
        "buster", "bullseye" : {
          file {
            '/etc/systemd/system/g5k-pmem-manager.service':
              source => 'puppet:///modules/env/std/g5k-manager/g5k-pmem-manager.service',
              ensure => file;
            '/usr/local/libexec/g5k-pmem-manager':
              source => 'puppet:///modules/env/std/g5k-manager/g5k-pmem-manager',
              mode => '0755',
              ensure => file;
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
      fail "$facts[os][name] not supported."
    }
  }
}

