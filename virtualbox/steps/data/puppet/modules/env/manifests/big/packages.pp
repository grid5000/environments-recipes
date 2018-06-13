class env::big::packages () {

  # editors
  $editors = [ 'jed', 'joe', 'emacs' ]

  $utils = [
    'at',
    'bash-completion',
    'bc',
    'bootlogd',
    'bsd-mailx',
    'clustershell',
    'connect-proxy',
    'cron',
    'db-util',
    'debhelper',
    'debian-archive-keyring',
    'debootstrap',
    'diffstat',
    'discover',
    'discover-data',
    'dnsutils',
    'dtach',
    'ftp',
    'genders',
    'gnuplot',
    'graphviz',
    'hdparm',
    'host',
    'html2text',
    'hwloc',
    'info',
    'inotify-tools',
    'iperf',
    'iputils-arping',
    'iputils-tracepath',
    'kanif',
    'kbd',
    'ldap-utils',
    'linux-tools'
    'lsb-release',
    'lshw',
    'lsof',
    'm4',
    'mysql-client',
    'netcat-openbsd',
    'nmap',
    'numactl',
    'nuttcp',
    'parallel',
    'postgresql-client',
    'pv',
    'r-base',
    'screen',
    'strace',
    'stress',
    'sudo',
    'telnet',
    'time',
    'tmux',
    'xauth',
    'xstow',
  ]

  # Dev and languages
  $general_dev = [
    'autoconf',
    'bison',
    'cgdb',
    'cmake',
    'cmake-curses-gui',
    'cvs',
    'flex',
    'gdb',
    'gfortran',
    'git-core',
    'libatlas-base-dev',
    'libatlas-dev','debconf-utils',
    'libboost-all-dev'
    'libc6',
    'libdate-calc-perl',
    'libdb-dev',
    'libjson-perl',
    'libjson-xs-perl',
    'libnetcdf-dev',
    'libnuma-dev',
    'libreadline6-dev',
    'libssl-dev',
    'libtool',
    'libyaml-0-2',
    'make',
    'patch',
    'php5-cli',
    'subversion',
    'tcl',
    'valgrind',
  ]

  $perl_dev = [
    'libwww-perl',
    'libperl-dev',
    'libswitch-perl',
  ]

  $python_dev = [
    'cython3',
    'ipython3',
    'python-dev',
    'python-httplib2',
    'python-imaging',
    'python-matplotlib-data',
    'python-matplotlib-doc',
    'python-mysqldb',
    'python-numpy',
    'python-paramiko',
    'python-pip',
    'python-psycopg2',
    'python-scipy',
    'python-sqlite',
    'python-yaml',
    'python3',
    'python3-cffi',
    'python3-dev',
    'python3-matplotlib',
    'python3-numpy',
    'python3-pandas',
    'python3-pip',
    'python3-scipy',
    'python3-setuptools',
    'python3-virtualenv',
    'python3-wheel',
  ]

  $ruby_dev = [
    'ruby-net-ssh-multi',
  ]

  $java_dev = [ 'openjdk-7-jdk', 'openjdk-7-jre', 'ant' ]

  $infiniband = [
    'ibverbs-utils',
    'libcxgb3-dev',
    'libipathverbs-dev',
    'libmlx4-dev',
    'libmthca-dev',
    'rdmacm-utils',
    'ibutils',
    'infiniband-diags',
    'perftest',
    'srptools',
  ]

  case $operatingsystem {
    'centos': {
      $dev = [
        $general_dev,
        $perl_dev,
        $python_dev,
        $ruby_dev,
        $java_dev,
        $infiniband,
        'gcc',
        'ruby-libs',
        'ruby-devel',
        'ruby-docs',
        'ruby-rack',
        'ruby-ri',
        'ruby-irb',
        'ruby-rdoc',
        'ruby-mode',
        'libwww-perl',
        'libperl-dev',
      ]}

    /^(Debian|Ubuntu)$/: {
      $dev = [
        $general_dev,
        $perl_dev,
        $python_dev,
        $ruby_dev,
        $java_dev,
        $infiniband,
        'build-essential',
        'binutils-doc',
        'ruby-dev',
        'ruby-rack',
        'ri',
        'libruby',
        'manpages-dev',
      ]}

    default: {
      $dev = [
        $general_dev,
        $perl_dev,
        $python_dev,
        $ruby_dev,
        $java_dev,
        $infiniband,
      ]}
  }

  $gems = [
    'mime-types',
    'rdoc',
    'rest-client',
    'restfully',
  ]

  # System tools
  $system = [
    'htop',
    'psmisc',
  ]

  file {
    '/etc/parallel/config':
      ensure  => absent,
      require => Package['parallel'];
    '/etc/at.allow':
      ensure  => present,
      owner   => root,
      group   => root,
      require => Package['at'];
    '/etc/cron.allow':
      ensure  => present,
      owner   => root,
      group   => root,
      require => Package['cron'];
  }

  package {
    [ $editors, $utils, $dev, $system ]:
      ensure   => installed;
    'rake_gem':
      name     => 'rake',
      provider => gem,
      ensure   => installed,
      require  => Package['ruby'];
    $gems:
      ensure   => installed,
      provider => gem,
      require  => [Package['rake_gem'], Package['ruby-rack']];
  }
}
