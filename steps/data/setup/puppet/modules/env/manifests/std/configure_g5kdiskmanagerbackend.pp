class env::std::configure_g5kdiskmanagerbackend {

  require env::std::install_hwraid_apt_source
  require env::std::configure_g5kmanager

  case $facts[os][name] {
    'Debian': {
      case $facts[os][distro][codename] {
        'buster', 'bullseye' : {
          file {
            '/etc/systemd/system/g5k-disk-manager-backend.service':
              ensure => file,
              source => 'puppet:///modules/env/std/g5k-manager/g5k-disk-manager-backend.service';
            '/usr/local/libexec/g5k-disk-manager-backend':
              ensure => file,
              mode   => '0755',
              source => 'puppet:///modules/env/std/g5k-manager/g5k-disk-manager-backend';
            '/etc/systemd/system/multi-user.target.wants/g5k-disk-manager-backend.service':
              ensure => link,
              target => '/etc/systemd/system/g5k-disk-manager-backend.service';
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

