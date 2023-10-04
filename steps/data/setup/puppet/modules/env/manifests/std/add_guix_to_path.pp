class env::std::add_guix_to_path {

  file {
    '/etc/profile.d/guix.csh':
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0644',
      content => template('env/std/guix/guix.csh.erb'),
      require => Package['guix'];
  }
}
