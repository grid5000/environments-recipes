class env::nfs::install_module () {

  case "${facts[os][distro][codename]}" {
    "buster": {
      # NOTHING
    }
    "bullseye", "bookworm" : {
      # Install lmod from g5kpackages (custom version that includes module-stats-wrapper)
      # Otherwise, for debian 10, lmod is installed with g5k-meta-packages
      env::common::g5kpackages {
        "lmod":
          release => "${facts[os][distro][codename]}",
          ensure => $::env::common::software_versions::lmod;
      }
    }
    default : {
      fail "${facts[os][distro][codename]} not supported."
    }
  }

  if ($facts[os][distro][codename] != 'buster') {
    $req = [
      Env::Common::G5kpackages['g5k-meta-packages'],
      Env::Common::G5kpackages["lmod"]
    ]
  } else {
    $req = [
      Env::Common::G5kpackages['g5k-meta-packages']
    ]
  }
}
