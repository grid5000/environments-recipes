class env::base::install_and_disable_ganglia ($enable = false){

  include env::common::software_versions

  if "$operatingsystem" == 'Debian' {
    env::common::g5kpackages {
      'ganglia-monitor':
        ensure  => $::env::common::software_versions::ganglia_monitor,
        release => "${::lsbdistcodename}";
    }
  }

  file {
    '/etc/ganglia' :
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => '0644',
  }

  case "${::lsbdistcodename}" {
    # ganglia 3.7.X
    'bullseye' : {
      file {
        '/etc/ganglia/gmond.conf' :
          ensure  => file,
          owner   => root,
          group   => root,
          mode    => '0644',
          source  => "puppet:///modules/env/base/ganglia/gmond-3.7.conf",
          require => File['/etc/ganglia'];
      }
    }
    # ganglia 3.6.X
    default : {
      file {
        '/etc/ganglia/gmond.conf' :
          ensure  => file,
          owner   => root,
          group   => root,
          mode    => '0644',
          source  => "puppet:///modules/env/base/ganglia/gmond-3.6.conf",
          require => File['/etc/ganglia'];
      }
    }
  }

  service {
    'ganglia-monitor':
      enable  => $enable,
      require => Package['ganglia-monitor'];
  }
}
