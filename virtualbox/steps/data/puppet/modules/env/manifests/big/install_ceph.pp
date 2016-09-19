class env::big::install_ceph (
  $version = 'firefly'
) {

  # bug ref. 7225 - changed commands to get ceph packages from apt.grid5000.fr
  file {
    '/etc/apt/sources.list.d/ceph.list':
      ensure  => file,
      mode    => '0644',
      owner   => root,
      group   => root,
      content => "deb http://apt.grid5000.fr/ceph5k/jessie/${version}"
  }

  # bug ref. 7225 - changed commands to install ceph from correct packages
  package {
    "ceph":
      ensure => '0.80.10-2~bpo8+1',
      require => File["/etc/apt/sources.list.d/ceph.list"];
    "chrony":
      ensure => installed;
    "ceph-common":
      ensure => '0.80.10-2~bpo8+1',
      require => File["/etc/apt/sources.list.d/ceph.list"];
    "python-ceph":
      ensure => '0.80.10-2~bpo8+1',
      require => File["/etc/apt/sources.list.d/ceph.list"];
    "librbd1":
      ensure => '0.80.10-2~bpo8+1',
      require => File["/etc/apt/sources.list.d/ceph.list"];
    "libcephfs1":
      ensure => '0.80.10-2~bpo8+1',
      require => File["/etc/apt/sources.list.d/ceph.list"];
    "librados2":
      ensure => '0.80.10-2~bpo8+1',
      require => File["/etc/apt/sources.list.d/ceph.list"];
  }

}

