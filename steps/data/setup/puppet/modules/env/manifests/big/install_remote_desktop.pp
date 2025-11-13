class env::big::install_remote_desktop() {
  file {
    default:
      ensure  => file,
      mode    => '0644',
      owner   => root,
      group   => root;
    '/etc/apt/trusted.gpg.d/TurboVNC.gpg':
      source  => 'puppet:///modules/env/big/turbovnc/TurboVNC.gpg';
    '/etc/apt/sources.list.d/TurboVNC.list':
      source => 'https://raw.githubusercontent.com/TurboVNC/repo/main/TurboVNC.list';
    '/etc/apt/trusted.gpg.d/VirtualGL.gpg':
      source  => 'puppet:///modules/env/big/virtualgl/VirtualGL.gpg';
    '/etc/apt/sources.list.d/VirtualGL.list':
      source => 'https://raw.githubusercontent.com/VirtualGL/repo/main/VirtualGL.list';
  }

  package {
    'xfce4':
      ensure => "${::env::common::software_versions::xfce4}";
    'websockify':
      ensure => "${::env::common::software_versions::websockify}";
    'turbovnc':
      ensure  => "${::env::common::software_versions::turbovnc}",
      require => [File['/etc/apt/sources.list.d/TurboVNC.list'], Class['apt::update']];
    'virtualgl':
      ensure  => "${::env::common::software_versions::virtualgl}",
      require => [File['/etc/apt/sources.list.d/VirtualGL.list'], Class['apt::update']];
  }
}
