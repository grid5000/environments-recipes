#!/bin/bash

set -euo pipefail

source .env
for var in GENERATED_ENV_VERSION CI_PIPELINE_ID CI_COMMIT_SHORT_SHA CI_COMMIT_SHA; do
    sed -i "s/\$${var}/${!var}/g" configuration.nix g5k-image.nix
done

# First generate the flake.lock file otherwise it will not be included in the generated tarball
nix --extra-experimental-features 'nix-command flakes' flake update
nix --extra-experimental-features 'nix-command flakes' build .#g5k-image
