class env::min::generate_etc_motd {

  case "${::lsbdistcodename}" {
    'trixie': {
      $userdistribname = "debian13"
    }
    'bookworm': {
      $userdistribname = "debian12"
    }
    'bullseye': {
      $userdistribname = "debian11"
    }
    'buster': {
      $userdistribname = "debian10"
    }
    default: {
      fail "${::lsbdistcodename} not supported."
    }
  }

  file {
    '/etc/motd':
      ensure  => file,
      owner   => root,
      group   => root,
      content => template('env/min/motd.erb'),
      mode    => '0755';
  }
}
