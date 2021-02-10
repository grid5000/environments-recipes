class env::big::configure_nvidia_gpu::ganglia () {

  case $operatingsystem {
    'Debian','Ubuntu': {

      case "${::lsbdistcodename}" {
        # ganglia 3.7.X
        'bullseye' : {
          # Unsupported ganglia-monitor-python-nvidia package for now
          #file{
          #  '/etc/ganglia/conf.d/modpython-nvidia.conf':
          #    ensure  => file,
          #    owner   => root,
          #    group   => root,
          #    mode    => '0644',
          #    source  => "puppet:///modules/env/big/nvidia/modpython-nvidia-3.7.conf",
          #    require => Package['ganglia-monitor-python-nvidia'];
          #  '/etc/systemd/system/ganglia-monitor.service':
          #    ensure  => file,
          #    owner   => root,
          #    group   => root,
          #    mode    => '0644',
          #    source  => "puppet:///modules/env/big/nvidia/ganglia-monitor-3.7-override.service",
          #    notify  => Service['ganglia-monitor'];
          # }
        }
        # ganglia 3.6.X
        default : {
          env::common::g5kpackages {
            'ganglia-monitor-nvidia':
              packages => 'ganglia-monitor-python-nvidia',
              ensure => installed;
          }

          Package['ganglia-monitor'] -> Package['ganglia-monitor-python-nvidia']

          file{
            '/etc/ganglia/conf.d/modpython-nvidia.conf':
              ensure  => file,
              owner   => root,
              group   => root,
              mode    => '0644',
              source  => "puppet:///modules/env/big/nvidia/modpython-nvidia.conf",
              require => Package['ganglia-monitor-python-nvidia'];
            '/etc/systemd/system/ganglia-monitor.service':
              ensure  => file,
              owner   => root,
              group   => root,
              mode    => '0644',
              source  => "puppet:///modules/env/big/nvidia/ganglia-monitor.service",
              notify  => Service['ganglia-monitor'];
           }
        }
      }
      exec {
        'enable ganglia-monitor':
          command => '/bin/systemctl enable ganglia-monitor',
          require => Package['ganglia-monitor'];
      }
    }
    default: {
      err "${operatingsystem} not supported."
    }
  }
}
