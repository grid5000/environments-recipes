class env::big::configure_initramfs () {

  case "${facts[os][distro][codename]}" {
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
    "bullseye", "bookworm" : {
      # NOTHING
    }
    default: {
      fail "${facts[os][distro][codename]} not supported."
    }
  }
}
