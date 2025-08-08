class env::std::g5k_generator {

  case $facts[os][name] {
    'Debian','Ubuntu': {

      #smbios-utils package for binary tool smbios-sys-info-lite
      package {
        'smbios-utils':
          ensure   => 'installed'
      }

      file {
        '/lib/systemd/system-generators/g5k-generator':
          ensure   => present,
          owner    => root,
          group    => root,
          mode     => '0755',
          source   => 'puppet:///modules/env/std/g5k_generator/g5k_generator',
          require  => Package['smbios-utils']
      }
    }
    default: {
      fail "$facts[os][name] not supported."
    }
  }
}
