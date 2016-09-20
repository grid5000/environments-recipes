class env::big::install_ceph (
  $version = 'firefly'
) {

  # bug ref. 7225 - updated URL to get ceph packages directly from jessie-backports
  file {
    '/etc/apt/sources.list.d/ceph.list':
      ensure  => file,
      mode    => '0644',
      owner   => root,
      group   => root,
      content => "deb https://download.ceph.com/debian-$version/ jessie main"
  }

  package {
    "ceph":
      require => File["/etc/apt/sources.list.d/ceph.list"];
  }

}

