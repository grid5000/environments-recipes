#!/usr/bin/env bash

set -euo pipefail

environment=""
architecture=""
variant=""
commit=""
tag=""
local_user=false

function usage {
  echo "Usage: $0 -e <env> -a <arch> -v <variant> -c <commit> -t <tag> [-l]"
  echo "Set '-l' to connect as the local user instead of ajenkins."
  exit 1
}

while getopts ":e:a:v:c:t:l" o; do
  case "${o}" in
    e)
      environment=${OPTARG}
      ;;
    a)
      architecture=${OPTARG}
      ;;
    v)
      variant=${OPTARG}
      ;;
    c)
      commit=${OPTARG}
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
if [ -z "${environment}" ] || [ -z "${architecture}" ] || [ -z "${variant}" ] || [ -z "${commit}" ] || [ -z "${tag}" ]; then
  usage
fi

set -x

# Create a temporary directory in which we'll work
TMP_DIR="$(mktemp -d)"

function remove_tmp_folder {
  rm -rf "${TMP_DIR}"
}

# Make sure we cleanup behind us.
trap remove_tmp_folder EXIT

environment_name="${environment}-${architecture}-${variant}"

readarray -d '' matching_envs < <(ssh nancy "find ~ajenkins/public/environments/pipelines/*-${commit} -name \"${environment_name}.dsc\" -print0")

if [ "${#matching_envs[@]}" -gt "1" ]; then
  # FIXME: maybe we can simply take the first one?
  echo "More than one matching pipeline (see below)! Please remove all but one before running the script again."
  printf '%s\n' "${matching_envs[@]}"
  exit 1
fi

if [ "${#matching_envs[@]}" -eq "0" ]; then
  echo "No pipeline found containing the requested env for the given commit, are you sure you generated the environment in gitlab?"
  exit 1
fi

echo "Found one env: ${matching_envs[0]}"
ENV_DIR=$(dirname ${matching_envs[0]})

echo "Fetching files for ${environment_name}"
# NOTE: this assumes that we are being ran as ajenkins
if [ "${local_user}" = true ]; then
  HOST="`whoami`@nancy"
else
  HOST="ajenkins@nancy"
fi

rsync -av ${HOST}:"${ENV_DIR}/${environment_name}.dsc" "${environment_name}-${tag}.dsc"

echo "I would do the following command but I'll touch instead:"
echo 'rsync -av ${HOST}:"${ENV_DIR}/${environment_name}.tar.zst" "${environment_name}-${tag}.tar.zst"'
touch "${environment_name}-${tag}.tar.zst"

echo "I would do the following command but I'll touch instead:"
echo 'rsync -av ${HOST}:"${ENV_DIR}/${environment_name}.qcow2" "${environment_name}-${tag}.qcow2"'
touch "${environment_name}-${tag}.qcow2"

# FIXME: intentionally no copying log: those are empty?!

# Let's fix the image url in the description file.
sed -e "s|\\(file: \\)[^$]*|\\1server:///grid5000/images/${environment_name}-${tag}.tar.zst|" -i "${environment_name}-${tag}.dsc"

ls "${TMP_DIR}"
cat "${TMP_DIR}"/*.dsc
# TODO: mv the files
# TODO: remove environment
# FIXME: check/figure out if/why we need to first do the deploy job
# TODO: register environment
# if env std:
# TODO: submit a deploy/destructive job to set the new std env
# TODO: wait
# TODO: release the job
