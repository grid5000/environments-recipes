# frozen_string_literal: true

require 'json'
require 'yaml'
require 'refrepo/data_loader'
require 'optparse'

require_relative 'config'

ARCH_TO_G5K_ARCH = {
  'x86_64' => 'x64',
  'ppc64le' => 'ppc64',
  'aarch64' => 'arm64',
}.freeze

VALID_ARCH_OPTIONS = ARCH_TO_G5K_ARCH.values.freeze

options = {}
OptionParser.new do |parser|
  parser.on('-o AAA', '--output', 'Output folder')
end.parse!(into: options)

unless File.directory?(options[:output])
  raise OptionParser::InvalidArgument, "'#{options[:output]}' is not an existing folder"
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

def clusters_per_arch
  res = {}
  all_sites.each do |site|
    clusters_per_arch_for_site(site).each do |arch, clusters|
      res[arch] ||= {}
      res[arch][site] = clusters
    end
  end
  res
end

def pipeline_for_config(clusters_config, os, version, arch, variants)
  # NOTE: I intentionally used the "rocket" notation for the hashes, because there
  # is not built-in way to stringify keys when using to_yaml, and extending
  # Psych::Visitors::YAMLTree's visit_Symbol seems a bit overkill for such a small
  # code.
  common_inputs = {
    'os' => os,
    'version' => version,
    'arch' => arch,
    # NOTE: just here to simplify a bit the static yaml
    'environment-name' => "#{os}-#{version}-#{arch}",
    'matrix-variants' => ".matrix-variants-#{variants.join('-')}",
  }
  generate_image_job = {
    'local' => 'ci/gitlab/generate-image.yml',
    'inputs' => {
      **common_inputs,
    },
  }
  tests_clusters_jobs = clusters_config[arch].map do |site, clusters|
    clusters.map do |cluster|
      {
        'local' => 'ci/gitlab/test-image-on-cluster.yml',
        'inputs' => {
          'site' => site,
          'cluster' => cluster,
          **common_inputs,
        },
      }
    end
  end.flatten
  {
    'stages' => ['generate', *all_sites],
    '.autostart' => {
      'variables' => {
        'GENERATE_OS' => ENV['GENERATE_OS'] || '',
        'TEST_CLUSTERS' => ENV['TEST_CLUSTERS'] || '',
      },
    },
    'include' => [
      'ci/gitlab/matrix-variants.yml',
      generate_image_job,
      *tests_clusters_jobs,
    ],
  }
end

clusters_config = clusters_per_arch

ENV_CONFIG.each do |os, versions|
  versions.each do |version, config|
    # FIXME: for now emit one file per arch, and with a matrix of variants
    config['archs'].each do |arch|
      pipeline = pipeline_for_config(clusters_config, os, version, arch, config['variants'])
      File.open("#{options[:output]}/#{os}-#{version}-#{arch}.yml", 'w') do |file|
        YAML.dump(pipeline, file)
      end
    end
  end
end
