#!/bin/bash
#OAR -n generate-nixos-image
#OAR -l nodes=1,walltime=1:00
#OAR -O OAR.%jobid%.stdout
#OAR -E OAR.%jobid%.stderr

set -euo pipefail

echo "Installing nix on standard environment..."
# We need super user rights to mount tmpfs and install nix
sudo-g5k
# There may not be enough space in / but we have a lot of RAM
sudo mkdir -p /nix
sudo mount -t tmpfs -o size=32G tmpfs /nix
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --daemon
source /etc/profile.d/nix.sh

echo "Running build script..."
# Remove previous result symlink if any
rm -f result
bash build-image.bash

# Load CI variables from .env file
source .env

TARGET_DIR="$HOME/public/environments/pipelines/$CI_PIPELINE_ID-$CI_COMMIT_SHORT_SHA"

echo "Removing old environments... (DISABLED)"
#find public/environments/pipelines/ -type f -mtime +14 -print -delete
#find public/environments/pipelines/ -type d -mtime +14 -empty -print -delete

echo "Copying environment to home ($TARGET_DIR) directory..."
mkdir -p $TARGET_DIR
rsync -rLv result/ $TARGET_DIR/
