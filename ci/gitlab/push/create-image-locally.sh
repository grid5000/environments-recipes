#!/usr/bin/env bash

set -euo pipefail

environment_name=""
commit=""
tag=""
oar_arch=""
local_user=false
site=""
is_std_env="no"

usage() {
  echo "Usage: $0 -e <environment_name> -c <commit> -s <site> -t <tag> -a <oar_arch> [-l]"
  echo "Set '-l' to connect as the local user instead of ajenkins."
  exit 1
}

while getopts ":a:e:c:t:s:l" o; do
  case "${o}" in
    a)
      oar_arch=${OPTARG}
      ;;
    e)
      environment_name=${OPTARG}
      ;;
    c)
      commit=${OPTARG}
      ;;
    s)
      site=${OPTARG}
      ;;
    t)
      tag=${OPTARG}
      ;;
    l)
      local_user=true
      ;;
    *)
      usage
      ;;
  esac
done

# NOTE: we intentionally do not check the values; we assume we only get called
# by scripts which know what they are doing.
# FIXME: checking that commit matches tag could be useful, but from a gitlab
# CI job we should have correct values.
if [ -z "${environment_name}" ] || [ -z "${oar_arch}" ] || [ -z "${commit}" ] || [ -z "${tag}" ] || [ -z "${site}" ]; then
  usage
fi

# Leaving this out of -x to avoid showing data on the command line
API_USER=$GL_API_USER
API_PASSWORD=$GL_API_PASSWORD

set -x

case ${environment_name} in
  *-std)
    is_std_env="yes"
    ;;
esac

# 80 retries of 15s makes it a 20 min timeout.
RETRIES=80
SLEEP_TIME=15

# Job state for std env
job_uid="0"
job_state="unknown"

create_job() {
  # real stuff
  #'{"resources":"{cpuarch='x86_64'}/nodes=BEST,walltime=0:10","name":"Update environments","command":"sleep infinity","types":["deploy","allowed=maintenance","exotic","destructive"],"queue":"admin"}'

  local status
  status=$(curl -k --output job.json --write-out "%{http_code}" "https://api-ext.grid5000.fr/3.0/sites/${site}/jobs" -X POST -H "Content-Type: application/json" -d "{\"resources\":\"{cpuarch='${oar_arch}'}/nodes=1,walltime=0:10\",\"name\":\"Test resa\",\"command\":\"sleep infinity\",\"types\":[\"allowed=maintenance\"],\"queue\":\"admin\"}" -K-<<< "--user ${API_USER}:${API_PASSWORD}")
  update_or_exit "$status" "201"
}

update_or_exit() {
  local status=$1
  local expected_status=$2
  if [ "${status}" != "${expected_status}" ]; then
    echo "Request failed with unexpected code, exiting"
    exit 1
  fi
  job_uid=$(jq -r '.uid' job.json)
  job_state=$(jq -r '.state' job.json)
}

get_job_data() {
  local job_id=$1
  local status
  status=$(curl -k --output job.json --write-out "%{http_code}" "https://api-ext.grid5000.fr/3.0/sites/lyon/jobs/${job_id}" -H'Content-Type: application/json' -K-<<< "--user ${API_USER}:${API_PASSWORD}")
  update_or_exit "$status" "200"
}

delete_job() {
  local job_id=$1
  # Just fire the curl, we would ignore an error anyway
  curl -k "https://api-ext.grid5000.fr/3.0/sites/lyon/jobs/${job_id}" -X DELETE -K-<<< "--user ${API_USER}:${API_PASSWORD}"
}


# Create a temporary directory in which we'll work
TMP_DIR="$(mktemp -d)"

function remove_tmp_folder {
  rm -rf "${TMP_DIR}"
}

# Make sure we cleanup behind us.
trap remove_tmp_folder EXIT

cd "${TMP_DIR}"

# Fetch all the generated descriptions by all the pipelines for tha commit
# At the moment they are all stored in ~ajenkins in Nancy.
# Sort them with reverse order to make sure the oldest (which has the highest
# pipeline id) comes up first.

# NOTE: we do want commit to expand client-side
# shellcheck disable=SC2029
readarray -d '' matching_envs < <(ssh nancy "find ~ajenkins/public/environments/pipelines/*-${commit} -name \"${environment_name}.dsc\" -print0 | sort -z -r")

if [ "${#matching_envs[@]}" -gt "1" ]; then
  echo "Warning: more than one matching pipeline (see below)! I will arbitrarily take the latest one."
  echo "---"
  printf '  - %s\n' "${matching_envs[@]}"
  echo "---"
fi

if [ "${#matching_envs[@]}" -eq "0" ]; then
  echo "Error: no pipeline found containing the requested env for the given commit, are you sure you generated the environment in gitlab?"
  exit 1
fi

echo "Using env: ${matching_envs[0]}"
env_dir=$(dirname "${matching_envs[0]}")

echo "Fetching files for ${environment_name}"

# NOTE: by default we assume that we are being ran as ajenkins, but to debug
# stuff let's also consider we might want to be ran as the local (aka: dev)
# user.
if [ "${local_user}" = true ]; then
  HOST="$(whoami)@nancy"
else
  HOST="ajenkins@nancy"
fi

# The environment name with the version/tag.
versioned_env_name="${environment_name}-${tag}"

# rsync the relevant files locally
rsync -av "${HOST}:${env_dir}/${environment_name}.dsc" "${versioned_env_name}.dsc"
rsync -av "${HOST}:${env_dir}/${environment_name}.tar.zst" "${versioned_env_name}.tar.zst"
# rsync/mv the qcow2 if needed
if [ "${is_std_env}" == "no" ]; then
  rsync -av "${HOST}:${env_dir}/${environment_name}.qcow2" "${versioned_env_name}.qcow2"
  mv "${versioned_env_name}.qcow2" /grid5000/virt-images
fi
# FIXME: intentionally no copying log: those are empty?!

# Let's fix the image url in the description file.
sed -e "s|\\(file: \\)[^$]*|\\1server:///grid5000/images/${environment_name}-${tag}.tar.zst|" -i "${versioned_env_name}.dsc"
# The image generation script set the version according to the time it's being
# generated.
# For now I just force the version to the tag value, is it better to make sure
# the user has set the tag according to the time it was generated?
# It seems tricky for cases where os-min and os-big are generated in two different
# pipelines which might be triggered at different times.
sed -e "s/version: [[:digit:]]\+/version: ${tag}/" -i "${versioned_env_name}.dsc"

# Now move the files to their final destinations
mv "${versioned_env_name}.dsc" /grid5000/descriptions
mv "${versioned_env_name}.tar.zst" /grid5000/images

# Remove (dev) environments if they exist
# Existence is tested through grepping "name:" in the description given by
# kaenv3, which exists only if there is indeed a description.
if /usr/bin/kaenv3 -u deploy -p "${environment_name}" --env-version "${tag}" --env-arch "${oar_arch}" | grep -q "name:"; then
  sudo -u deploy /usr/bin/kaenv3 --yes -d "${environment_name}" -u deploy --env-version "${tag}" --env-arch "${oar_arch}"
fi

if /usr/sbin/kaenv3-dev -u deploy -p "${environment_name}" --env-version "${tag}" --env-arch "${oar_arch}" | grep -q "name:"; then
  sudo -u deploy /usr/sbin/kaenv3-dev --yes -d "${environment_name}" -u deploy --env-version "${tag}" --env-arch "${oar_arch}"
fi

# If we are dealing with the std env, let's create a BEST destructive job on the
# site.
if [ "${is_std_env}" == "yes" ]; then
  # Create a job and wait for it.
  create_job
  if [ "${tries}" -lt "${RETRIES}" ] && [ "${job_state}" != "running" ]; then
    tries=$((tries + 1))
    echo "Try ${tries}/${RETRIES}."
    sleep ${SLEEP_TIME}
    get_job_data "${job_uid}"
  fi
  # We've either timed out or a job.
  if [ "${job_state}" != "running" ]; then
    echo "Could not get a job, aborting"
    exit 1
  fi
fi

# Register the newly built environment
sudo -u deploy /usr/bin/kaenv3 -a "/grid5000/descriptions/${versioned_env_name}.dsc"
sudo -u deploy /usr/sbin/kaenv3-dev -a "/grid5000/descriptions/${versioned_env_name}.dsc"

if [ "${is_std_env}" == "yes" ]; then
  delete_job "${job_uid}"
fi
