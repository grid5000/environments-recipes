class env::big::configure_perftools {

    package {
        "linux-tools":
            ensure => installed;
    }

    file {
        '/etc/sysctl.d/perftools.conf':
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '644',
        content => 'kernel.perf_event_paranoid=-1';
    }
}
