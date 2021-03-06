# coding: utf-8

# INSTALLED BY PUPPET
# Location : puppet/modules/env/files/std/g5k-manager/lib/g5k-manager.rb

require 'open-uri'
require 'json'
require 'optparse'

def sh(cmd)
  output = `#{cmd}`.chomp
  status = $?.exitstatus
  return [status, output]
end

# systemd log levels:
# see http://0pointer.net/blog/projects/journal-submit.html
# and http://man7.org/linux/man-pages/man3/syslog.3.html
def notice(msg)
  log_notice = 5 # normal, but significant, condition
  puts "<#{log_notice}> #{msg}"
end

def debug(msg)
  log_debug = 7 # debug-level message
  puts "<#{log_debug}> #{msg}" if DEBUG
end

def error(status, msg)
  log_err = 3 # error conditions
  puts "<#{log_err}> #{msg}"
  rmtmp
  exit status
end

def rmtmp
  if defined?(TMPDIR)
    Dir.chdir('/root')
    sh("rm -rf #{TMPDIR}")
  end
end

# If property 'soft'='free', the standard environment is being
# deployed by an admin (outside a job) or phoenix.
# Else, it is a user that is deploying the standard environment
# For the different states, see:
# https://github.com/grid5000/g5k-api/blob/master/lib/oar/resource.rb#L45
def user_deploy?(hostname)
  tries = 3
  begin
    url = G5K_API + '/sites/' + site(hostname) + '/status?disks=no&job_details=no&waiting=no&network_address=' + hostname
    hash = JSON::parse(open(url, 'User-Agent' => 'g5k-manager (for disk and pmem)').read)
  rescue
    tries -= 1
    if tries > 0
      debug("Fetching #{url} failed. Sleeping 1s and retry.")
      sleep(1)
      retry
    else
      error(1, "Fetching #{url} failed too many times")
    end
  end

  status = hash['nodes'][hostname]
  debug("Node status: soft=#{status['soft']}, hard=#{status['hard']}")
  user_deploy = (status['hard'] == 'alive' and status['soft'] != 'free')
  return user_deploy
end

def cluster(hostname)
  return hostname.split('-')[0]
end

def site(hostname)
  return hostname.split('.')[1]
end

G5K_API = 'https://api.grid5000.fr/stable'
DEBUG = true
