class env::std::install_kameleon {

  case $facts[os][name] {
    'Debian': {
      case $facts[os][distro][codename] {
        'buster', 'bullseye': {
          env::common::g5kpackages {
            'kameleon':
              ensure  =>  $::env::common::software_versions::kameleon,
              release => $facts[os][distro][codename];
          }
        }
        default: {
          fail "${facts[os][distro][codename]} not supported."
        }
      }
    }
    default: {
      fail "${facts[os][name]} not supported."
    }
  }
}
