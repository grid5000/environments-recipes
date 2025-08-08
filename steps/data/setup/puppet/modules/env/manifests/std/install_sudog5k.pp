class env::std::install_sudog5k {

  case $facts[os][name] {
    'Debian': {
      require env::commonpackages::rake
      require env::commonpackages::rubyrspec
      require env::commonpackages::rsyslog

      # See bug #13901
      if $facts[os][distro][codename] == 'bookworm' {
        env::common::g5kpackages {
          'ruby-net-ssh_bookworm':
          ensure => $::env::common::software_versions::ruby_net_ssh;
        }
      }

      env::common::g5kpackages {
        'sudo-g5k':
          ensure => $::env::common::software_versions::sudo_g5k;
      }

    }
    default: {
      fail "$facts[os][name] not suported."
    }
  }

  file {
    '/etc/sudo-g5k/id_rsa_sudo-g5k':
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0600',
      source  => 'puppet:///modules/env/std/sudo-g5k/id_rsa_sudo-g5k',
      require => Package['sudo-g5k'];
  }
}
