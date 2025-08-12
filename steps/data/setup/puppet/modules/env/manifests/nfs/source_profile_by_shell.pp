class env::nfs::source_profile_by_shell {

      stdlib::ensure_packages(['zsh','tcsh'], {ensure => installed})

      file {
        '/etc/csh/cshrc.d':
          ensure  => 'directory',
          require => Package['tcsh'],
          owner   => root,
          group   => root,
          mode    => '0755';
        default:
          ensure => file,
          owner  => 'root',
          group  => 'root',
          mode   => '0644';
        '/etc/bash.bashrc.g5k':
          source => 'puppet:///modules/env/nfs/source_profile_by_shell/bash.bashrc.g5k';
        '/etc/zsh/zshenv.g5k':
          require => Package['zsh'],
          source  => 'puppet:///modules/env/nfs/source_profile_by_shell/zshenv.g5k';
        '/etc/csh/cshrc.d/csh.cshrc.g5k':
          require => File['/etc/csh/cshrc.d'],
          source  => 'puppet:///modules/env/nfs/source_profile_by_shell/csh.cshrc.g5k';
      }

      file_line { 'source /etc/bash.bashrc.g5k file':
          ensure => present,
          path   => '/etc/bash.bashrc',
          line   => '. /etc/bash.bashrc.g5k',
          after  => '# this file has to be sourced in /etc/profile.'
      }

      file_line { 'source /etc/zsh/zshenv.g5k file':
          ensure  => present,
          require => Package['zsh'],
          path    => '/etc/zsh/zshenv',
          line    => '. /etc/zsh/zshenv.g5k'
      }
    }
