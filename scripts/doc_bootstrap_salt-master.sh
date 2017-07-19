#!/bin/bash
##
## https://docs.mirantis.com/mcp/master/mcp-deployment-guide/install-base-infra/install-salt-master/bootstrap-salt-master.html
## Bootstrap the Salt Master node
##

git clone $RECLASS_DEPLOYMENT_GIT_URL /srv/salt/reclass
test ! -e .gitmodules || git submodule update --init --recursive

cd /srv/salt/scripts
#MASTER_HOSTNAME=cfg01.lab777.local ./salt-master-init.sh
# export MASTER_HOSTNAME=cfg01.lab777.local
./salt-master-init.sh
