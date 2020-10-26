class env::base::enable_cpupower_with_performance_governor (){

  package {
    'linux-cpupower':
      ensure   => installed;
  }

  file {
    '/usr/lib/systemd/scripts':
      ensure   => directory,
      owner    => root,
      group    => root,
      mode     => '0755',
  }

  file {
    '/usr/lib/systemd/scripts/cpupower':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0755',
      source   => 'puppet:///modules/env/base/cpupower/cpupower',
      require  => File['/usr/lib/systemd/scripts'];
  }

  file {
    '/usr/lib/systemd/system/cpupower.service':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0644',
      source   => 'puppet:///modules/env/base/cpupower/cpupower.service';
  }

  file {
    '/etc/systemd/system/multi-user.target.wants/cpupower.service':
      ensure   => link,
      target   => '/etc/systemd/system/cpupower.service';
  }

  file {
    '/etc/default/cpupower':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0644',
      source   => 'puppet:///modules/env/base/cpupower/cpupower.default';
  }
}
