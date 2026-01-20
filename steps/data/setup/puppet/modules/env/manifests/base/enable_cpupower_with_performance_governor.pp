class env::base::enable_cpupower_with_performance_governor (){

  package {
    'linux-cpupower':
      ensure   => installed;
  }

  file {
    '/etc/default/cpupower':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0644',
      source   => 'puppet:///modules/env/base/cpupower/default'
  }
}
