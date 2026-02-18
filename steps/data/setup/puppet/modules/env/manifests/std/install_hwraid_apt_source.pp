class env::std::install_hwraid_apt_source {

  include apt

  case "${::lsbdistcodename}" {
    'trixie' : {
      # apt-key is no more supported
      file {
        "/usr/share/keyrings/hwraid.gpg":
          ensure   => file,
          owner    => root,
          group    => root,
          mode     => '0644',
          content => template('env/std/hwraid/hwraid.le-vert.net.key.erb');
        "/etc/apt/sources.list.d/hwraid.list":
          ensure  => present,
          content => "deb [signed-by=/usr/share/keyrings/hwraid.gpg] http://hwraid.le-vert.net/debian ${::lsbdistcodename} main",
          notify  => Class['apt::update'],
          require => File["/usr/share/keyrings/hwraid.gpg"],
      }
    }
    'buster', 'bullseye' : {
      apt::source { 'hwraid.le-vert.net':
        key      => {
          'id'      => '9B241597ACC8C086A363535E43676E103A9A6F7C',
          'content' => template('env/std/hwraid/hwraid.le-vert.net.key.erb'),
        },
        comment  => 'Repo for megacli package',
        location => 'http://hwraid.le-vert.net/debian',
        release  => "${::lsbdistcodename}",
        repos    => 'main',
          include  => {
            'deb' => true,
            'src' => false
        }
      }
    }
    default : {
      fail "${::lsbdistcodename} not supported."
    }
  }
}
