class env::std::install_hwraid_apt_source {

  include apt

  # FIXME : mettre source_release sur buster quand ce sera supporté
  case "${::lsbdistcodename}" {
    "buster" : {
      $source_release = "stretch"
    }
    default : {
      $source_release = "${::lsbdistcodename}"
    }
  }

  apt::source { 'hwraid.le-vert.net':
    key      => {
      'id'      => '6005210E23B3D3B4',
      'content' => template('env/std/hwraid/hwraid.le-vert.net.key.erb'),
    },
    comment  => 'Repo for megacli package',
    location => 'http://hwraid.le-vert.net/debian',
    release  => "${source_release}",
    repos    => 'main',
     include  => {
      'deb' => true,
      'src' => false
    }
   }
}
