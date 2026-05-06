class env::std::fix_swap {

  if $facts['service_provider'] == 'systemd' {
    file { '/etc/systemd/system/fix_swap.service':
      ensure => file,
      source => 'puppet:///modules/env/std/fix_swap/fix_swap.service',
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }
    service { 'fix_swap':
      enable => true,
    }
  }
}
