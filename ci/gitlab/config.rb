# frozen_string_literal: true

require 'refrepo/data_loader'

ARCHS_ALL = %w[x64 arm64 ppc64].freeze
ARCHS_X_ARM = %w[x64 arm64].freeze
ARCHS_ARM = %w[arm64].freeze
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
      'archs' => ARCHS_ARM,
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
    '2404' => {
      'archs' => ARCHS_X_ARM,
      'variants' => VARIANTS_MIN_NFS,
    },
    'l4t200435' => {
      'archs' => ARCHS_ARM,
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
  'almalinux' => {
    '9' => {
      'archs' => ARCHS_X_ARM,
      'variants' => VARIANTS_MIN_NFS,
    },
  },
}.freeze

def env_name(os, version, arch, variant)
  "#{os}#{version}-#{arch}-#{variant}"
end

def map_all_envs
  ENV_CONFIG.map do |os, versions|
    versions.map do |version, config|
      config['archs'].map do |arch|
        config['variants'].map do |variant|
          yield os, version, arch, variant
        end
      end
    end
  end
end

ALL_ENVS = map_all_envs(&method(:env_name)).flatten.freeze

ARCH_TO_G5K_ARCH = {
  'x86_64' => 'x64',
  'ppc64le' => 'ppc64',
  'aarch64' => 'arm64',
}.freeze

G5K_ARCH_TO_ARCH = {
  'x64' => 'x86_64',
  'ppc64' => 'ppc64le',
  'arm64' => 'aarch64',
}.freeze

def valid_env?(name)
  ALL_ENVS.include?(name)
end

REF = load_data_hierarchy.freeze

def all_sites
  REF['sites'].keys
end

def clusters_for_site(site)
  REF['sites'][site]['clusters'].keys
end

def clusters_per_arch_for_site(site)
  clusters = clusters_for_site(site)

  archs_per_cluster = clusters.to_h do |c|
    # Since all nodes in a cluster have the same arch, we can look only at
    # the first node's architecture.
    arch = REF['sites'][site]['clusters'][c]['nodes'].values.first['architecture']['platform_type']
    # Convert arch to g5k's funky arch names.
    [c, ARCH_TO_G5K_ARCH[arch]]
  end
  # Group clusters per arch and return them
  archs_per_cluster.keys.group_by { |k| archs_per_cluster[k] }
end