class env::std::add_lmod_to_path {

  file {
    '/etc/profile.d/lmod.csh':
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0644',
      source  => 'puppet:///modules/env/std/lmod/lmod.csh',
      require => Package['lmod'];
  }
}
