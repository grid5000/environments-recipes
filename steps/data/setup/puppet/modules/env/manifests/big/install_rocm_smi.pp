class env::big::install_rocm_smi () {

  # rocm-smi package provided since Debian 12 Bookworm
  # required for g5k-checks (Bug #18590)

  case $::lsbdistcodename {

    'trixie', 'bookworm' : {
      package {
        'rocm-smi':
          ensure => installed;
      }
    }
    default: {
      fail "${::lsbdistcodename} not supported."
    }
  }
}
