#!/bin/bash

set -euo pipefail

nix --extra-experimental-features 'nix-command flakes' build .#g5k-image
