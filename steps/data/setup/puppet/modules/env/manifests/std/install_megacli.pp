class env::std::install_megacli {

  case "${::lsbdistcodename}" {
    'trixie' : {
      # pick and install package using local mirrored bullseye repository (bug #17875)
      exec {
        'retrieve_megacli':
          command   => "/usr/bin/wget -q http://packages.grid5000.fr/deb/hwraid/pool-bullseye/megacli/megacli_8.07.14-3+Debian.11.bullseye_amd64.deb -O /tmp/megacli.deb",
          creates   => "/tmp/megacli.deb";
        'retrieve_libncurses5':
          command   => "/usr/bin/wget -q http://ftp.fr.debian.org/debian/pool/main/n/ncurses/libncurses5_6.2+20201114-2+deb11u2_amd64.deb -O /tmp/libncurses5.deb",
          creates   => "/tmp/libncurses5.deb";
        'retrieve_/tmp/libtinfo5':
          command   => "/usr/bin/wget -q http://ftp.fr.debian.org/debian/pool/main/n/ncurses/libtinfo5_6.2+20201114-2+deb11u2_amd64.deb -O /tmp/libtinfo5.deb",
          creates   => "/tmp/libtinfo5.deb";
        'install_megacli':
          command     => "/usr/bin/dpkg -i /tmp/megacli.deb /tmp/libncurses5.deb /tmp/libtinfo5.deb",
          user        => root;
      }
    }
    default : {
      require env::std::install_hwraid_apt_source
      package {
        'megacli':
          ensure => installed,
          require  => [Apt::Source['hwraid.le-vert.net'], Exec['apt_update']]
      }
    }
  }
}
