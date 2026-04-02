class env::std::install_bridge {
# cf. Bug #18142

  case "${::lsbdistcodename}" {
    'trixie' : {
      package {
        'bridge-utils':
          ensure => installed
      }
    }
    default: {
      fail "${operatingsystem} not supported."
    }
  }

}
