class env::std::install_kameleon {

  case $operatingsystem {
    'Debian': {
      case "${lsbdistcodename}" {
        'trixie': {
          package {
            'kameleon':
              install_options => ['-t', "${lsbdistcodename}-backports", "--no-install-recommends"],
              ensure   => installed;
          }
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
