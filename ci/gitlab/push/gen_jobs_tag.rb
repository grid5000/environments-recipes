# frozen_string_literal: true

require 'json'
require 'yaml'
require 'refrepo/data_loader'
require 'optparse'

require_relative 'config'

options = {}
OptionParser.new do |parser|
  parser.on('-o AAA', '--output', 'Output folder')
  parser.on('-t TTT', '--tag', 'Tag')
end.parse!(into: options)

ENV_NAME=options[:tag].split('/').first

unless File.directory?(options[:output])
  raise OptionParser::InvalidArgument, "'#{options[:output]}' is not an existing folder"
end

REF = load_data_hierarchy.freeze

def all_sites
  REF['sites'].keys
end

# This function generate the necessary include to generate all the images
# for ENV_NAME.
# TODO: there is a discussion to have here, do we want to :
#   - assume all images have already been generated (eg: by a manual pipeline on the tagged commit)?
#   - disregard all previous generations and *just* use image generation from this pipeline?
#   - a bit of both: we have the tagged commit, so we could look for the already
#   generated images, and generate the missing one(s).
# I'll let these jobs in manual for now.
def gen_environments_includes
  map_all_envs do |os, version, arch, variant|
    environment = env_name(os, version, arch, variant)
    next unless environment.start_with?(ENV_NAME)
    common_inputs = {
      'environment-name' => environment,
    }
    {
      'local' => 'ci/gitlab/generate-image.yml',
      'inputs' => {
        'autostart' => false,
        **common_inputs,
      },
    }
  end.flatten.compact
end

# TODO: create per site push job
def main_pipeline
  {
    'stages' => ['generate', *all_sites],
    'include' => [
      *environments_pipelines,
    ],
  }
end

File.open("#{options[:output]}/main-tag.yml", 'w') do |file|
  YAML.dump(main_pipeline, file)
end
