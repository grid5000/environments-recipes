class env::big::install_smartd {

  package {
    'smartmontools':
      ensure => installed;
  }

  file {
    '/etc/systemd/system/smartd.service.d/':
      ensure  => directory,
      require => Package['smartmontools'];
    '/etc/systemd/system/smartd.service.d/override.conf':
      ensure  => present,
      content => "[Service]\nExecStartPre=mkdir -p /dev/discs",
      require => File['/etc/systemd/system/smartd.service.d/'];
  }

  file_line { 'smartd.conf':
    ensure  => present,
    require => Package['smartmontools'],
    path    => '/etc/smartd.conf',
    line    => 'DEVICESCAN -d nvme -d scsi -d ata -d sat -n standby -m root -M exec /usr/share/smartmontools/smartd-runner',
    match   => '^DEVICESCAN .*';
  }

  # Since Bookworm, smartmontools fails if there is nothing to monitor
  case "${::lsbdistcodename}" {
    # Bug 18116 - smartmontools v7.4, "-q nodev0" : the exit status is 0 if there are no devices to monitor.
    'trixie': {
      file_line { 'smartmontools_config':
        ensure  => present,
        require => Package['smartmontools'],
        path    => '/etc/default/smartmontools',
        line    => 'smartd_opts="--quit=nodev0"',
      }
    }
    # Bug 15290 - smartmontools v7.3, "-q never" lets smartd continue to run, waiting to load a configuration file listing valid devices.
    'bookworm': {
      file_line { 'smartmontools_config':
        ensure  => present,
        require => Package['smartmontools'],
        path    => '/etc/default/smartmontools',
        line    => 'smartd_opts="--quit=never"',
      }
    }
  }
}
