class env::big::configure_initramfs () {

  case "${::lsbdistcodename}" {
    "bullseye", "bookworm", "trixie" : {
      # Nothing
    }
    "buster" : {
      file {
        '/etc/initramfs-tools/conf.d/resume':
          ensure    => present,
          owner     => root,
          group     => root,
          mode      => '0644',
          content   => 'RESUME=none',
      }
    }
    default: {
      fail "${::lsbdistcodename} not supported."
    }
  }
}
