class env::base::enable_cpupower_with_performance_governor (){

  package {
    'linux-cpupower':
      ensure   => installed;
  }

  file {
    '/etc/systemd/system/cpupower.service':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => File['/usr/local/sbin/cpupower-service', '/etc/default/cpupower'],
      source  => 'puppet:///modules/env/base/cpupower/cpupower.service';
    '/usr/local/sbin/cpupower-service':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0755',
      require  => Package['linux-cpupower'],
      source   => 'puppet:///modules/env/base/cpupower/cpupower-service';
    '/etc/default/cpupower':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0644',
      source   => 'puppet:///modules/env/base/cpupower/default';
  }

  service {
    'cpupower.service':
      enable => true,
  }

}
