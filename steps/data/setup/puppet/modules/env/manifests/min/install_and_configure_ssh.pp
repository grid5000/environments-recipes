class env::min::install_and_configure_ssh {

  case $facts[os][name] {
    'Debian','Ubuntu': {

      package {
        'ssh server':
          ensure => present,
          name   => 'openssh-server';
      }

      service {
        'ssh':
          ensure => running,
          name   => 'ssh';
      }

    }

    'Centos': {

      package {
        'ssh server':
          ensure => present,
          name   => 'sshd';
      }

      service {
        'ssh':
          ensure => running,
          name   => 'sshd';
      }

    }
  }

  package {
    'ssh client':
      ensure => present,
      name   => 'openssh-client';
  }

  augeas {
    'sshd_config_min':
      incl    => '/etc/ssh/sshd_config',
      lens    => 'Sshd.lns',
      changes => [
        'set /files/etc/ssh/sshd_config/PermitUserEnvironment yes',
        'set /files/etc/ssh/sshd_config/MaxStartups 500'
      ],
      require => Package['ssh server'];
  }
  # Todo: 'check that key files are overwritten by postinstall'

  Augeas['sshd_config_min'] ~> Service['ssh']

}

