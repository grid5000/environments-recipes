class env::min::install_metapackage ( $variant ) {

  include stdlib
  include env::common::software_versions

  case $facts[os][name] {
    'Debian': {
      case $facts[os][distro][codename] {
        'trixie': {
          $base = 'g5k-meta-packages-debian13'
        }
        'bookworm': {
          $base = 'g5k-meta-packages-debian12'
        }
        'bullseye': {
          $base = 'g5k-meta-packages-debian11'
        }
        'buster': {
          $base = 'g5k-meta-packages-debian10'
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

  $g5kmetapackages = "${base}-${variant}"

  $pinned = join(['min', 'base', 'nfs','big'].map |$env| { "${base}-${env}" },' ')

  env::common::apt_pinning {
    'g5k-meta-packages':
      packages => $pinned,
      version  => $::env::common::software_versions::g5k_meta_packages
  }

  env::common::g5kpackages {
    'g5k-meta-packages':
      ensure   => $::env::common::software_versions::g5k_meta_packages,
      packages => $g5kmetapackages,
      require  => Env::Common::Apt_pinning['g5k-meta-packages'];
  }

}
