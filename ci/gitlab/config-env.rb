ARCHS_ALL = %w[x64 arm64 ppc64].freeze
ARCHS_X = %w[x64].freeze
ARCHS_X_ARM = %w[x64 arm64].freeze
ARCHS_ARM = %w[arm64].freeze
VARIANTS_ALL = %w[min base nfs big std rocm].freeze
VARIANTS_ALL_BUT_ROCM = %w[min base nfs big std].freeze
VARIANTS_ALL_BUT_STD_ROCM = %w[min base nfs big].freeze
VARIANTS_MIN_NFS = %w[min nfs].freeze
VARIANTS_MIN_NFS_BIG = %w[min nfs big].freeze

def map_variants_to_archs(variants, archs)
  variants.map { |variant| [variant, archs] }.to_h
end

ENV_CONFIG = {
  'debian' => {
    '11' =>  map_variants_to_archs(VARIANTS_ALL_BUT_ROCM, ARCHS_ALL),
    '12' =>  map_variants_to_archs(VARIANTS_MIN_NFS_BIG, ARCHS_ALL),
    '13' =>  map_variants_to_archs(VARIANTS_ALL_BUT_ROCM, ARCHS_ALL),
    'testing' =>  map_variants_to_archs(VARIANTS_MIN_NFS, ARCHS_ALL),
    'l4t1135' =>  map_variants_to_archs(%w[std], ARCHS_ARM),
    'gh11' => map_variants_to_archs(%w[std], ARCHS_ARM),
  },
  'ubuntu' => {
    '2004' =>  map_variants_to_archs(VARIANTS_MIN_NFS, ARCHS_ALL),
    '2204' =>  map_variants_to_archs(VARIANTS_MIN_NFS, ARCHS_X_ARM),
    '2404' => {
      'min' => ARCHS_X_ARM,
      'nfs' => ARCHS_X_ARM,
      'rocm' => ARCHS_X,
    },
    'l4t200435' => map_variants_to_archs(%w[big], ARCHS_ARM),
    'gh2404' => map_variants_to_archs(%w[big], ARCHS_ARM),
  },
  'centosstream' => {
    '8' => map_variants_to_archs(VARIANTS_MIN_NFS, ARCHS_X_ARM),
    '9' => map_variants_to_archs(VARIANTS_MIN_NFS, ARCHS_X_ARM),
  },
  'rocky' => {
    '8' => map_variants_to_archs(VARIANTS_MIN_NFS, ARCHS_X_ARM),
    '9' => map_variants_to_archs(VARIANTS_MIN_NFS, ARCHS_X_ARM),
  },
  'almalinux' => {
    '9' => map_variants_to_archs(VARIANTS_MIN_NFS, ARCHS_X_ARM),
  },
}.freeze

def env_name(os, version, arch, variant)
  "#{os}#{version}-#{arch}-#{variant}"
end

def map_all_envs
  ENV_CONFIG.map do |os, versions|
    versions.map do |version, variants|
      variants.map do |variant, archs|
        archs.map do |arch|
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
