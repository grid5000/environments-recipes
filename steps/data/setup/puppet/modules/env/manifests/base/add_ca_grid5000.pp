# Add ca2019.grid5000.fr certificate

class env::base::add_ca_grid5000 {

  file {
    'ca2019_grid5000':
      ensure => 'file',
      path   => '/usr/local/share/ca-certificates/ca2019.grid5000.fr.crt',
      owner  => root,
      group  => root,
      mode   => '0644',
      source => 'puppet:///modules/env/base/add_ca_grid5000/ca2019.grid5000.fr.crt';
  }
  exec {
    'update_ca':
      command => "/usr/sbin/update-ca-certificates",
      require => File['ca2019_grid5000'];
  }

}
