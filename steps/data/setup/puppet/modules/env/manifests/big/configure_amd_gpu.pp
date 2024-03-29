class env::big::configure_amd_gpu () {

  case $::lsbdistcodename {

    'buster' : {
      apt::source {
        'repo.radeon.com':
          comment      => 'Repo for AMD ROCM packages',
          location     => "https://repo.radeon.com/rocm/apt/${::env::common::software_versions::rocm_version}/",
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

      package {
        [ 'rock-dkms', 'hip-base', 'rocminfo', 'rocm-smi-lib', 'hip-rocclr', 'rocm-device-libs', 'libtinfo5', 'hsa-amd-aqlprofile' ]:
          ensure          => installed,
          install_options => ['--no-install-recommends'],
          require         => [Apt::Source['repo.radeon.com'], Exec['apt_update']];
      }

      exec {
        'add_rocm_symlink':
          command => "/bin/ln -s /opt/rocm-*/ /opt/rocm",
          require => Package['rocm-smi-lib'];
      }

      file {
        '/usr/local/bin/rocm-smi':
          ensure  => link,
          target  => '/opt/rocm/bin/rocm-smi',
          require => [Package['rocm-smi-lib'], Exec['add_rocm_symlink']];
        '/etc/udev/rules.d/70-amdgpu.rules':
          ensure  => present,
          owner   => root,
          group   => root,
          mode    => '0644',
          source  => 'puppet:///modules/env/big/amd_gpu/70-amdgpu.rules',
          require => Package['rock-dkms'];
      }
    }

    'bullseye', 'bookworm' : {
      include env::big::configure_amd_gpu_bullseye_bookworm_common
    }

    default: {
      fail "${::lsbdistcodename} not supported."
    }
  }

  file {
    '/etc/profile.d/rocm.sh':
      ensure  => present,
      owner => root,
      group => root,
      mode  => '0644',
      content => 'export PATH=$PATH:/opt/rocm/bin';
  }

  file {
    '/etc/ld.so.conf.d/rocm.conf':
      ensure  => present,
      owner => root,
      group => root,
      mode  => '0644',
      source => 'puppet:///modules/env/big/amd_gpu/rocm.conf';
  }
}

class env::big::configure_amd_gpu_bullseye_bookworm_common () {
  apt::source {
    'repo.radeon.com-amdgpu':
      comment      => 'Repo for AMDGPU packages',
      location     => $::lsbdistcodename ? {
                        'bullseye' => 'https://repo.radeon.com/amdgpu/21.40/ubuntu/',
                        'bookworm' => 'https://repo.radeon.com/amdgpu/23.20.00.48/ubuntu/',
                        default    => '',
                      },
      release      =>  $::lsbdistcodename ? {
                        'bullseye' => 'focal',
                        'bookworm' => 'jammy',
                        default    => '',
                      },
      repos        => 'main',
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

  apt::source {
    'repo.radeon.com-rocm':
      comment      => 'Repo for AMD ROCM packages',
      location     => "https://repo.radeon.com/rocm/apt/${::env::common::software_versions::rocm_version}/",
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

  package {
    'amdgpu-dkms':
      ensure          => installed,
      install_options => ['--no-install-recommends'],
      require         => [Apt::Source['repo.radeon.com-amdgpu'], Exec['apt_update']];
    [ 'hip-dev', 'rocminfo', 'rocm-smi-lib', 'rocm-device-libs', 'rocm-hip-runtime', 'hsa-amd-aqlprofile' ]:
      ensure          => installed,
      install_options => ['--no-install-recommends'],
      require         => [Apt::Source['repo.radeon.com-rocm'], Exec['apt_update'], Exec['build_and_install_rocm_llvm']];
  }

  exec {
    'build_and_install_rocm_llvm':
      command  => "mkdir /tmp/rocm && cd /tmp/rocm && apt download rocm-llvm && dpkg-deb -x rocm-llvm_*.deb rocm-llvm && dpkg-deb --control rocm-llvm_*.deb rocm-llvm/DEBIAN && sed -i 's/^Depends: .*/Depends: libc6/g' rocm-llvm/DEBIAN/control && dpkg -b rocm-llvm/ rocm-llvm.deb && apt install -y ./rocm-llvm.deb && rm -fr /tmp/rocm",
      provider => shell,
      timeout  => 1800,
      require  => [Apt::Source['repo.radeon.com-rocm'], Exec['apt_update']];
    'add_rocm_symlink':
      command => "/bin/ln -s /opt/rocm-*/ /opt/rocm",
      require => Package['rocm-smi-lib'];
  }

  file {
    '/usr/local/bin/rocm-smi':
      ensure  => link,
      target  => '/opt/rocm/bin/rocm-smi',
      require => Package['rocm-smi-lib'];
    '/etc/udev/rules.d/70-amdgpu.rules':
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0644',
      source  => 'puppet:///modules/env/big/amd_gpu/70-amdgpu.rules',
      require => Package['amdgpu-dkms'];
  }
}
