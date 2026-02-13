class env::big::configure_amd_gpu () {

  $amdgpu_source_url = "https://repo.radeon.com/amdgpu/${::env::common::software_versions::amdgpu_version}/ubuntu"

  $amdgpu_releases = {
    'buster'   => 'ubuntu',
    'bullseye' => 'focal',
    'bookworm' => 'jammy',
    'trixie'   => 'noble'
  }
  case $::lsbdistcodename {
    'buster' : {
      apt::source {
        'repo.radeon.com':
          comment      => 'Repo for AMD ROCM packages',
          location     => $rocm_source_url,
          release      => 'ubuntu',
          repos        => 'main',
          architecture => 'amd64',
          key          => {
            'id'     => '1A693C5C',
            'source' => 'https://repo.radeon.com/rocm/rocm.gpg.key',
          },
          include      => {
            'deb' => true,
            'src' => false
          },
          notify       => Exec['apt_update'],
      }
    }

    default : {
      exec {
        'retrieve rocm key':
          command => "/usr/bin/wget https://repo.radeon.com/rocm/rocm.gpg.key -O - | gpg --dearmor | tee /etc/apt/trusted.gpg.d/rocm.gpg > /dev/null";
      }

      apt::source {
        'repo.radeon.com-amdgpu':
          comment      => 'Repo for AMD AMDGPU packages',
          location     => $amdgpu_source_url,
          release      => $amdgpu_releases[$::lsbdistcodename],
          repos        => 'main',
          architecture => 'amd64',
          require      => Exec['retrieve rocm key'],
          notify       => Exec['apt_update'],
          include  => { 'deb' => true, 'src' => false }
      }
    }
  }

  package {
    'amdgpu-dkms':
      ensure          => installed,
      install_options => ['--no-install-recommends'],
      require         => [Apt::Source['repo.radeon.com-amdgpu'], Exec['apt_update']],
      notify          => Exec['generate_initramfs'];
  }

  file {
    '/etc/udev/rules.d/70-amdgpu.rules':
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0644',
      source  => 'puppet:///modules/env/big/amd_gpu/70-amdgpu.rules',
      require => Package['amdgpu-dkms'];
  }
}


