class env::base::configure_dhcpcd () {

  require env::commonpackages::rsyslog

  # from slaac private to hwaddr (Bug #17449)
  file_line { 'dhcpcd_slaac_hwaddr':
    ensure => present,
    path   => '/etc/dhcpcd.conf',
    line   => 'slaac hwaddr',
    match  => '^#slaac hwaddr$',
  }
  file_line { 'dhcpcd_slaac_private':
    ensure => present,
    path   => '/etc/dhcpcd.conf',
    line   => '#slaac private',
    match  => '^slaac private$',
  }

}
