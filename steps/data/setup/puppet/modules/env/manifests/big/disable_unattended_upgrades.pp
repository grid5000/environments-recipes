class env::big::disable_unattended_upgrades {

  case $facts[os][distro][codename] {
    'bookworm': {
        # Disable unattended-upgrades service
        service { 'unattended-upgrades':
            enable => false,
        }
    }
  }
}
