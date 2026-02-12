class env::big::configure_rocm () {

  include env::big::configure_amd_gpu

  $rocm_source_url = "https://repo.radeon.com/rocm/apt/${::env::common::software_versions::rocm_version}/"

  $rocm_releases = {
    'buster'   => 'ubuntu',
    'bullseye' => 'focal',
    'bookworm' => 'jammy',
    'trixie'   => 'noble'
  }

  # Common packages
  apt::source {
    'repo.radeon.com-rocm':
      comment      => 'Repo for AMD ROCM packages',
      location     => $rocm_source_url,
      release      => $amdgpu_releases[$::lsbdistcodename],
      repos        => 'main',
      architecture => 'amd64',
      require      => Exec['retrieve rocm key'],
      notify       => Exec['apt_update'],
      include  => { 'deb' => true, 'src' => false }
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

  package {
    [ 'rocminfo', 'rocm-smi-lib', 'rocm-device-libs', 'hsa-amd-aqlprofile' ]:
      ensure          => installed,
      install_options => ['--no-install-recommends'],
      require         => Apt::Source['repo.radeon.com-rocm'];
  }

  file {
    '/usr/local/bin/rocm-smi':
      ensure  => link,
      target  => '/opt/rocm/bin/rocm-smi',
      require => Package['rocm-smi-lib'];
  }

  case $::lsbdistcodename {
    # Specific packages
    'buster' : {
      package {
        [ 'rock-dkms', 'hip-base', 'hip-rocclr', 'libtinfo5']:
          ensure          => installed,
          install_options => ['--no-install-recommends'],
          require         => Apt::Source['repo.radeon.com-rocm'];
      }

      exec {
        'add_rocm_symlink':
          command => "/bin/ln -s /opt/rocm-*/ /opt/rocm",
          require => Package['rocm-smi-lib'];
      }
    }

    'bullseye', 'bookworm' : {
      exec {
        'build_and_install_rocm_llvm':
          command  => "mkdir /tmp/rocm && cd /tmp/rocm && apt download rocm-llvm && dpkg-deb -x rocm-llvm_*.deb rocm-llvm && dpkg-deb --control rocm-llvm_*.deb rocm-llvm/DEBIAN && sed -i 's/^Depends: .*/Depends: libc6/g' rocm-llvm/DEBIAN/control && dpkg -b rocm-llvm/ rocm-llvm.deb && apt install -y ./rocm-llvm.deb && rm -fr /tmp/rocm",
          provider => shell,
          timeout  => 1800,
          require  => Apt::Source['repo.radeon.com-rocm'];
      }
      file {
        '/etc/apt/preferences.d/rocm-pin-600':
          ensure  => present,
          content => "Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600",
          require => Apt::Source['repo.radeon.com-rocm'],
          notify  => Exec['apt_update'];
      }
      package {
        [ 'hip-dev', 'rocm-hip-runtime']:
          ensure          => installed,
          install_options => ['--no-install-recommends'],
          require         => Exec['build_and_install_rocm_llvm'];
      }
    }

    default: {
      fail "${::lsbdistcodename} not supported."
    }
  }
}
