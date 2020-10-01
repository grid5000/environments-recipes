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
      mode    => '0644';
    '/etc/ganglia/gmond.conf' :
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0644',
      source  => "puppet:///modules/env/base/ganglia/gmond.conf",
      require => File['/etc/ganglia'];
  }

  # Debian jessie suffers a bug that make puppet unable to correctly detect if some services are enabled or not (https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=760616 or #bug=751638 )
  # Because of this bug, service ganglia-monitor can't be made "disabled" with the standard method.
  if "${::lsbdistcodename}" == "jessie" and "${::operatingsystem}" == "Debian" {
    unless $enable {
      exec {
        'disable ganglia-monitor':
          command => '/bin/systemctl disable ganglia-monitor',
          require => Package['ganglia-monitor'];
      }
    }
  }
  else {
    service {
      'ganglia-monitor':
        enable  => $enable,
        require => Package['ganglia-monitor'];
    }
  }
}
