class env::big::configure_nvidia_gpu::ganglia () {

  case $operatingsystem {
    'Debian','Ubuntu': {

      env::common::g5kpackages {
        'ganglia-monitor-nvidia':
          packages => 'ganglia-monitor-python-nvidia',
          ensure => installed;
      }

      Package['ganglia-monitor'] -> Package['ganglia-monitor-python-nvidia']

      case "${::lsbdistcodename}" {
        # ganglia 3.7.X
        'bullseye' : {
          file{
            '/etc/ganglia/conf.d/modpython-nvidia.conf':
              ensure  => file,
              owner   => root,
              group   => root,
              mode    => '0644',
              source  => "puppet:///modules/env/big/nvidia/modpython-nvidia-3.7.conf",
              require => Package['ganglia-monitor-python-nvidia'];
            '/etc/systemd/system/ganglia-monitor.service':
              ensure  => file,
              owner   => root,
              group   => root,
              mode    => '0644',
              source  => "puppet:///modules/env/big/nvidia/ganglia-monitor-3.7-override.service",
              notify  => Service['ganglia-monitor'];
           }
        }
        # ganglia 3.6.X
        default : {
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
      service {
        'ganglia-monitor':
          enable    => true;
      }
    }
    default: {
      err "${operatingsystem} not supported."
    }
  }

}
