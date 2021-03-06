class env::nfs::configure_module_path () {

  # Configure module path (installed in g5k-metapackage)
  case "$env::deb_arch" {
    "amd64": {
      $modulespath = "/grid5000/spack/share/spack/modules/linux-debian9-x86_64\n/grid5000/spack/share/spack/modules/linux-debian10-x86_64\n"
    }
    "ppc64el": {
      $modulespath = "/grid5000/spack/share/spack/modules/linux-debian10-ppc64le\n"
    }
    default: {
      $modulespath = ""
    }
  }

  file {
    '/etc/lmod/modulespath':
      ensure   => file,
      backup   => '.puppet-bak',
      content  => $modulespath,
      require  => Env::Common::G5kpackages['g5k-meta-packages'];
  }
}
