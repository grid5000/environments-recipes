class env::big::install_g5k-jupyterlab {
  case $operatingsystem {
    'Debian': {

      include env::common::software_versions

      env::common::g5kpackages {
        'g5k-jupyterlab':
          ensure => $::env::common::software_versions::g5k-jupyterlab;
      }
    }
    default: {
      err "${operatingsystem} not suported."
    }
  }
}

