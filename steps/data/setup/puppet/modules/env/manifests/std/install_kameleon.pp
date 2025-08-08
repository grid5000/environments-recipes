class env::std::install_kameleon {

  case $facts[os][name] {
    'Debian': {
      case "${facts[os][distro][codename]}" {
        'buster', 'bullseye': {
          env::common::g5kpackages {
            'kameleon':
              release => "${facts[os][distro][codename]}",
              ensure =>  $::env::common::software_versions::kameleon;
          }
        }
        default: {
          fail "${facts[os][distro][codename]} not supported."
        }
      }
    }
    default: {
      fail "$facts[os][name] not supported."
    }
  }
}
