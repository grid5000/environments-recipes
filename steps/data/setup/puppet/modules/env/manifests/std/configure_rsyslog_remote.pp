class env::std::configure_rsyslog_remote {

  require env::commonpackages::rsyslog

  file {
    "/etc/rsyslog.conf":
      mode    => '0600',
      owner   => root,
      group   => root,
      source  => "puppet:///modules/env/std/net_access/rsyslog.conf";
    "/etc/rsyslog.d/syslog_iptables.conf":
      mode    => '0655',
      owner   => root,
      group   => root,
      source  => "puppet:///modules/env/std/net_access/syslog_iptables.conf";
  }

  # iptables installed by kameleon.
  file {
    "/etc/network/if-pre-up.d/iptables":
      mode    => '0755',
      owner   => root,
      group   => root,
      source  => "puppet:///modules/env/std/net_access/iptables"
  }
}

