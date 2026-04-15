# installed by puppet
# file steps/data/setup/puppet/modules/env/files/nfs/xdg_runtime_dir/xdg_runtime_dir.sh
# module env::nfs::configure_xdg_runtime_dir

mkdir -p /tmp/$USER-runtime-dir
export XDG_RUNTIME_DIR=/tmp/$USER-runtime-dir
