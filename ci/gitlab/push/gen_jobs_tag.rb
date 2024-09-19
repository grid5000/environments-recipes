# frozen_string_literal: true

require 'json'
require 'yaml'
require 'refrepo/data_loader'
require 'optparse'

require_relative '../config'

options = {}
OptionParser.new do |parser|
  parser.on('-o AAA', '--output', 'Output folder')
  parser.on('-t TTT', '--tag', 'Tag')
end.parse!(into: options)

# FIXME: check the tag name matches 'envname/YYYYMMDDXX'
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
    {
      'local' => 'ci/gitlab/generate-image.yml',
      'inputs' => {
        'autostart' => false,
        'environment-name' => environment,
      },
    }
  end.flatten.compact
end

def gen_environments_push
  # NOTE: I would have loved to use includes here too, but there is a 150
  # includes limit that we hit :(
  # For these jobs it's not bad so I have inlined them.

  # Start by gathering all environments
  selected_envs = map_all_envs do |os, version, arch, variant|
    environment = env_name(os, version, arch, variant)
    next unless environment.start_with?(ENV_NAME)
    environment
  end.flatten.compact
  base_pipeline = {
    'stages' => ['generate', *selected_envs],
  }
  stuff = selected_envs.reduce(base_pipeline) do |jobs, environment|
    all_sites.each do |site|
      jobs.merge!({
        "#{site}-#{environment}" => {
          'stage' => environment,
          'variables' => {
            'AUTOSTART' => false,
            'ENV_NAME' => environment,
            'SITE' => site,
          },
          # We start the job automatically if we're told to do so, otherwise we put
          # the job in manual mode.
          'rules' => [
            { 'if' => '$AUTOSTART == "true"' },
            { 'when' => 'manual' },
          ],
          # FIXME: either "need" the generate job, or probably nothing actually!
          'needs' => [],
          'tags' => %w(grid5000-shell),
          'script' => [
            'echo "Pushing ${ENV_NAME} on ${SITE}"',
            'echo "FIXME: when testing is over I would use commit ${CI_COMMIT_SHORT_SHA}"',
            # NOTE: currently this is a harmless rsync/cat of some files
            'ci/gitlab/push/create-image-locally.sh -e ${ENV_NAME} -c 62b4ee8a -t ${CI_COMMIT_TAG}',
          ],
        }
      })
    end
    jobs
  end
end

def main_pipeline
  {
    'stages' => ['generate', *all_sites],
    'include' => [
      *gen_environments_includes,
    ],
    **gen_environments_push,
  }
end

File.open("#{options[:output]}/main-tag.yml", 'w') do |file|
  YAML.dump(main_pipeline, file)
end
