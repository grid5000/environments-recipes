class env::min::install_metapackage ( $variant ) {

  include stdlib
  include env::common::software_versions

  $g5kmetapackages = "g5k-meta-packages-${variant}"

  $pinned = join(['min', 'base', 'nfs','big'].map |$env| { "g5k-meta-packages-${env}" }," ")

  env::common::apt_pinning {
    'g5k-meta-packages':
      packages => $pinned,
      version => $::env::common::software_versions::g5k_meta_packages
  }

  env::common::g5kpackages {
    'g5k-meta-packages':
      packages => $g5kmetapackages,
      ensure   => $::env::common::software_versions::g5k_meta_packages,
      release  => "${lsbdistcodename}",
      require  => Env::Common::Apt_pinning['g5k-meta-packages'];
  }

}
