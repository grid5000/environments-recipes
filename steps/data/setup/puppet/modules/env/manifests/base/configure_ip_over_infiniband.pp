class env::base::configure_ip_over_infiniband (){

  case "${::lsbdistcodename}" {
    'buster': {
      # En suivant la doc https://wiki.debian.org/RDMA, vous n'avez pas besoin d'installer opensm sur les environnements
      # Il risque de rentrer en conflit avec d'autres instances d'OpenSM présent sur du matériel réseau, ou bien sur des clusters externes à Grid5000 (exemple : https://intranet.grid5000.fr/bugzilla/show_bug.cgi?id=10747)

      service {
        'openibd':
          provider => 'systemd',
          enable   => true,
          require  => [
            File['/etc/systemd/system/openibd.service']
          ];
      }
    }

    default: {
      $infiniband_packages = ['qlvnictools']

      ensure_packages([$infiniband_packages], {'ensure' => 'installed'})

      if "${::lsbdistcodename}" == "stretch" {
        service {
          'openibd':
            provider => 'systemd',
            enable   => true,
            require  => [
              Package[$infiniband_packages],
              File['/etc/systemd/system/openibd.service']
            ];
        }
      } else {
        if "${::lsbdistcodename}" == "jessie" {
          service {
            'openibd':
              enable   => true,
              require  => [
                Package[$infiniband_packages],
                File['/etc/init.d/openibd']
              ];
          }
        }
      }
    }
  }

  file {
    '/etc/infiniband':
      ensure   => directory,
      owner    => root,
      group    => root,
      mode     => '0644';
    '/etc/infiniband/openib.conf':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0644',
      source   => 'puppet:///modules/env/base/infiniband/openib.conf',
      require  => File['/etc/infiniband'];
    '/etc/init.d/openibd':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0755',
      source   => 'puppet:///modules/env/base/infiniband/openibd';
    '/etc/systemd/system/openibd.service':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0644',
      source   => 'puppet:///modules/env/base/infiniband/openibd.service';
    '/lib/udev/rules.d/90-ib.rules':
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0644',
      source  => 'puppet:///modules/env/base/infiniband/90-ib.rules';
  }
}
