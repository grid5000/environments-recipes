class env::min::configure_network_and_install_drivers {

  # Network configuration
  file {
    '/etc/hosts':
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        source => 'puppet:///modules/env/min/network/hosts';
  }

  case $facts['os']['distro']['codename'] {
    # Since Debian 13 trixie, isc-dhcp-client is replaced by dhcpcd
    # same hook is applied with different file path
    'trixie': {
      file {
        '/etc/dhcpcd.exit-hook':
          owner  => 'root',
          group  => 'root',
          mode   => '0644',
          source => 'puppet:///modules/env/min/network/g5k-update-host-name';
      }
    }
    default: {
      file {
        '/etc/dhcp/dhclient-exit-hooks.d/g5k-update-host-name':
          owner  => 'root',
          group  => 'root',
          mode   => '0644',
          source => 'puppet:///modules/env/min/network/g5k-update-host-name';
      }
    }
  }

  # Network driver for many dell server, arm pyxis cluster (qlogic), servan cluster ice (misc-nonfree)
  case $facts[os][name] {
    'Debian': {
      $drivers = ['firmware-bnx2x', 'firmware-bnx2', 'firmware-qlogic', 'firmware-misc-nonfree']
    }
    'Ubuntu': {
      $drivers = ['linux-firmware']
    }
  }

  package {
    $drivers:
      ensure   => installed;
  }

}
