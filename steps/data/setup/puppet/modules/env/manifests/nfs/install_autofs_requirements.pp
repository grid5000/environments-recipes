class env::nfs::install_autofs_requirements(){

  case "${facts[os][distro][codename]}" {
    "buster": {
      package {
        'autofs':
          ensure => installed;
      }
    }
    "bullseye", "bookworm" : {
      env::common::g5kpackages {
        'autofs-g5k':
          # see bug 13638
          ensure => '5.1.2-4',
          packages => ['autofs'],
          release => $facts[os][distro][codename];
      }
    }
    default : {
      fail "${facts[os][distro][codename]} not supported."
    }
  }

  service {
    'autofs':
      ensure => running,
      require => Package['autofs'];
  }
}
