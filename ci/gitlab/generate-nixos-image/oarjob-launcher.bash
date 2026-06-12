#!/bin/bash
#OAR -n generate-nixos-image
#OAR -l nodes=1,walltime=1:00
#OAR -t deploy
#OAR -O OAR.%jobid%.stdout
#OAR -E OAR.%jobid%.stderr

set -euo pipefail

echo "Deploying NixOS image..."
kadeploy3 -u lschoepp nixos-x86_64-linux

NODE=$(head -n 1 $OAR_NODE_FILE)

# Remove any existing known host entry for the node to avoid warnings
ssh-keygen -f "/home/ajenkins/.ssh/known_hosts" -R $NODE

echo "Copying flake and build script to $NODE..."
ssh -o StrictHostKeyChecking=no root@$NODE mkdir -p /build/
rsync -v flake.nix configuration.nix build-image.bash root@$NODE:/build/

echo "Running build script on $NODE..."
ssh -o StrictHostKeyChecking=no root@$NODE "cd /build && bash build-image.bash"

# Load CI variables from .env file
source .env

TARGET_DIR="$HOME/public/environments/pipelines/$CI_PIPELINE_ID-$CI_COMMIT_SHORT_SHA"

echo "Removing old environments... (DISABLED)"
#find public/environments/pipelines/ -type f -mtime +14 -print -delete
#find public/environments/pipelines/ -type d -mtime +14 -empty -print -delete

echo "Copying environment to home ($TARGET_DIR) directory..."
mkdir -p $TARGET_DIR
rsync -rLv root@$NODE:/build/result/ $TARGET_DIR/
