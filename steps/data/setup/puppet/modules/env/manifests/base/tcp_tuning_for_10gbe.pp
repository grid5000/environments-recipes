class env::base::tcp_tuning_for_10gbe (){


# *** Setting up TCP buffers
#
# See: https://www.grid5000.fr/w/TCP_bandwidth_tuning
#

  file {
    '/etc/sysctl.d/00-grid5000.conf':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0644',
      source   => 'puppet:///modules/env/base/tuning/sysctl-00-grid5000.conf';
  }
}

# C-state are DISABLED on node for jessie (and later?) environments, variant base and above (xen, big, std, nfs).
# This is done in Kadeploy description file. Parameter intel_idle.max_cstate=0 and idle=poll are used (cf image dsc file, or kaenv -p jessie-x64-{base,xen,nfs,big,std})

