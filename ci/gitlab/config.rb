# frozen_string_literal: true

ARCHS_ALL = %w[x64 arm64 ppc64].freeze
ARCHS_X_ARM = %w[x64 arm64].freeze
VARIANTS_ALL = %w[min base nfs big std].freeze
VARIANTS_ALL_BUT_STD = %w[min base nfs big].freeze
VARIANTS_MIN_NFS = %w[min nfs].freeze
VARIANTS_MIN_NFS_BIG = %w[min nfs big].freeze

ENV_CONFIG = {
  'debian' => {
    '10' => {
      'archs' => ARCHS_ALL,
      'variants' => VARIANTS_ALL_BUT_STD,
    },
    '11' => {
      'archs' => ARCHS_ALL,
      'variants' => VARIANTS_ALL,
    },
    '12' => {
      'archs' => ARCHS_ALL,
      'variants' => VARIANTS_MIN_NFS_BIG,
    },
    'testing' => {
      'archs' => ARCHS_ALL,
      'variants' => VARIANTS_MIN_NFS,
    },
    'l4t1135' => {
      'archs' => %w[arm64],
      'variants' => %w[std],
    },
  },
  'ubuntu' => {
    '2004' => {
      'archs' => ARCHS_ALL,
      'variants' => VARIANTS_MIN_NFS,
    },
    '2204' => {
      'archs' => ARCHS_X_ARM,
      'variants' => VARIANTS_MIN_NFS,
    },
    'l4t200435' => {
      'archs' => %w[arm64],
      'variants' => %w[big],
    },
  },
  'centosstream' => {
    '8' => {
      'archs' => ARCHS_X_ARM,
      'variants' => VARIANTS_MIN_NFS,
    },
    '9' => {
      'archs' => ARCHS_X_ARM,
      'variants' => VARIANTS_MIN_NFS,
    },
  },
  'rocky' => {
    '8' => {
      'archs' => ARCHS_X_ARM,
      'variants' => VARIANTS_MIN_NFS,
    },
    '9' => {
      'archs' => ARCHS_X_ARM,
      'variants' => VARIANTS_MIN_NFS,
    },
  },
  'centos' => {
    '7' => {
      'archs' => ARCHS_ALL,
      'variants' => VARIANTS_MIN_NFS,
    },
    '8' => {
      'archs' => ARCHS_ALL,
      'variants' => VARIANTS_MIN_NFS,
    },
  },
}.freeze
