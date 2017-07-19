#!/bin/bash
# Redirect all outputs
exec > >(tee -i /tmp/mk-reclass.log) 2>&1
set -x
CLUSTER_MODEL_ARC=${CLUSTER_MODEL_ARC:-'~ubuntu/lab777.tar.gz'}
SYSTEM_MODEL_GIT_URL=${SYSTEM_MODEL_GIT_URL:-'https://github.com/Mirantis/reclass-system-salt-model'}
RECLASS_HOME=${RECLASS_HOME:-'/srv/salt/reclass'}

# generate model at https://10.10.100.8/ (lab777.tar.gz in the example)
mkdir -p $RECLASS_HOME
cd $RECLASS_HOME
git init
git config --global user.name "$USER"
git config --global user.email "$USER@$(hostname)"

tar -xzf $CLUSTER_MODEL_ARC

mkdir -p classes/cluster
git submodule add $SYSTEM_MODEL_GIT_URL classes/system/
#test ! -e .gitmodules || git submodule update --init --recursive
git add classes/system
git commit -am "Initial commit cluster model $CLUSTER_MODEL_ARC and sys model $SYSTEM_MODEL_GIT_URL"


