class env::nfs::configure_xdg_runtime_dir () {

  file {
    '/etc/profile.d/xdg_runtime_dir.sh':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => 'puppet:///modules/env/nfs/xdg-runtime-dir/xdg_runtime_dir.sh';
  }
}
