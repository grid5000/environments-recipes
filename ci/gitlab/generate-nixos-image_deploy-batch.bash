#!/bin/bash
#OAR -n generate-nixos-image
#OAR -l nodes=1,walltime=1:00
#OAR -t deploy
#OAR -O OAR.%jobid%.stdout
#OAR -E OAR.%jobid%.stderr

set -euo pipefail

echo "Deploying NixOS image..."
kadeploy3 -u lschoepp nixos-x86_64-linux

# $OAR_NODE_FILE is natively populated by OAR at runtime
NODE=$(head -n 1 $OAR_NODE_FILE)

echo "Running nix build on $NODE..."
ssh -o StrictHostKeyChecking=no root@$NODE "
  set -euo pipefail
  mkdir -p /build
  cd /build
  nix --extra-experimental-features 'nix-command flakes' flake init --template 'github:oar-team/nixos-g5k-image#minimal'
  nix --extra-experimental-features 'nix-command flakes' build .#g5k-image
"
