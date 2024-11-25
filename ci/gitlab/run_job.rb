#!/usr/bin/env ruby
# frozen_string_literal: true

require 'genenvgenerator'
require 'genenvtester'
require 'genenvpusher'
require 'optparse'
require_relative 'config'

options = {}
# TODO: we could use the cloned refrepo to also:
#  - validate the cluster
#  - validate the site.

OptionParser.new do |parser|
  parser.on('-j JJJ', '--job', %w[build test push], 'Job to run')
  parser.on('-e EEE', '--env', 'Environment name')
  parser.on('-c CCC', '--cluster', 'Cluster on which to run the test (including the site, eg: "lyon-nova")')
  parser.on('-s SSS', '--site', 'Site on which to push the environment')
  parser.on('-r RRR', '--refapi', 'Refapi branch to use')
end.parse!(into: options)

raise OptionParser::InvalidArgument, 'You must specify a job to run' unless options[:job]
raise OptionParser::InvalidArgument, 'You must specify an environment name' unless options[:env]
raise OptionParser::InvalidArgument, "Invalid environment #{options[:env]}" unless valid_env?(options[:env])

case options[:job]
when 'build'
  GenEnvGenerator.new.generate(options[:env], nil, nil, 'http://public.lyon.grid5000.fr/~cdevaux/g5k-postinstall.tgz')
when 'test'
  raise OptionParser::InvalidArgument, 'You must specify a cluster' unless options[:cluster]
  raise OptionParser::InvalidArgument, 'You must specify the refapi branch' unless options[:refapi]

  GenEnvTester.new.test(options[:cluster], options[:env], nil, options[:refapi], true)
when 'push'
  raise OptionParser::InvalidArgument, 'You must specify a site' unless options[:site]

  GenEnvPusher.new.push(options[:site], options[:env])
else
  raise "Unknown job type: #{options[:job]}"
end
