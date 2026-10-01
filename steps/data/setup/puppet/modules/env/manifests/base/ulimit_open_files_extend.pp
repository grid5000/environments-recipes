class env::base::ulimit_open_files_extend (){

# *** Setting up 128 * 1024 open files limit
#
# See: https://support.inria.fr/Ticket/Display.html?id=385359
#

  file {
    '/etc/security/limits.d/grid5000-ulimit.conf':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0644',
      source   => 'puppet:///modules/env/base/tuning/grid5000-ulimit.conf';
  }
}

