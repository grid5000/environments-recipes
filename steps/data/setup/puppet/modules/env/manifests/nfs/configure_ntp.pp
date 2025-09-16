class env::nfs::configure_ntp ( $drift_file = false ) {

  case "${::lsbdistcodename}" {
    "trixie": {
      $ntp = [ 'ntpsec', 'ntpsec-ntpdate' ]
      $ntp_conf_file = '/etc/ntpsec/ntp.conf'
      $ntp_drift_file = '/var/lib/ntp/ntp.drift'
    }
    default: {
      $ntp = [ 'ntp', 'ntpdate' ]
      $ntpconf = '/etc/ntp.conf'
      $ntp_drift_file = '/var/lib/ntpsec/ntp.drift'
    }
  }

  package {
    'ntpdate':
      ensure    => installed;
    'ntp':
      ensure    => installed,
      require   => Package['openntpd'];
    'openntpd':
      ensure    => absent;
  } # Here we forced ntp package to be 'ntp' and not 'openntp' because ntp is listed as dependencie by g5kchecks and conflict openntp.

  file {
    $ntp_conf_file:
      ensure    => file,
      owner     => root,
      group     => root,
      mode      => '0644',
      content   => template("env/nfs/ntp/ntp.conf.erb"),
      notify    => Service['ntp'];
  }

  if $drift_file {
    file {
      $ntp_drift_file:
        ensure    => file,
        owner     => ntp,
        group     => ntp,
        mode      => '0644',
        content   => "",
        require   => Package[$ntp];
    }
  }

  service {
    'ntp':
      enable    => true;
  }
}
