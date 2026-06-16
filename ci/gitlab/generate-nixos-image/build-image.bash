#!/bin/bash

set -euo pipefail

source .env
sed -i "s/\$GENERATED_ENV_VERSION/${GENERATED_ENV_VERSION}/" configuration.nix
sed -i "s/\$CI_PIPELINE_ID/${CI_PIPELINE_ID}/" configuration.nix
sed -i "s/\$CI_COMMIT_SHORT_SHA/${CI_COMMIT_SHORT_SHA}/" configuration.nix
sed -i "s/\$CI_COMMIT_SHA/${CI_COMMIT_SHA}/" configuration.nix

nix --extra-experimental-features 'nix-command flakes' build .#g5k-image
