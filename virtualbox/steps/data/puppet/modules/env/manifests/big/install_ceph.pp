class env::big::install_ceph (
  $version = 'hammer'
) {

  $key = '460F3994'

  # bug ref. 7225 - changed commands to get ceph packages from apt.grid5000.fr
  exec {
    'get_ceph_key':
      command  => "/usr/bin/wget -q -O- 'https://download.ceph.com/keys/release.asc' | /usr/bin/apt-key add -",
      unless    => "/usr/bin/apt-key list | /bin/grep '${key}'";
  }

  file {
    '/etc/apt/sources.list.d/ceph.list':
      ensure  => file,
      mode    => '0644',
      owner   => root,
      group   => root,
      content => "deb https://download.ceph.com/debian-$version/ jessie main"
  }

  exec {
    'install_ceph':
      command  => "/usr/bin/apt-get -y --force-yes install ceph",
      unless    => "/usr/bin/apt-key list | /bin/grep '${key}'";
  }

  Exec['get_ceph_key'] -> File['/etc/apt/sources.list.d/ceph.list'] -> Exec['install_ceph']
}

