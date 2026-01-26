class env::std::install_kameleon {

  case $operatingsystem {
    'Debian': {
      case "${lsbdistcodename}" {
        'trixie': {
          # no Kameleon packages for now (Bug #17936)
        }
        'buster', 'bullseye': {
          env::common::g5kpackages {
            'kameleon':
              release => "${lsbdistcodename}",
              ensure =>  $::env::common::software_versions::kameleon;
          }
        }
        default: {
          fail "${lsbdistcodename} not supported."
        }
      }
    }
    default: {
      fail "${operatingsystem} not supported."
    }
  }
}
