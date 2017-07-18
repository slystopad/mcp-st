#!/bin/bash
#
#
codename=xenial
# 12.04 | 14.04 | 16.04
version=16.04
# salt master
config_host=$SALT_MASTER_HOST
node_name=$(hostname)

echo "Preparing base OS ..."

which wget >/dev/null || (apt-get update; apt-get install -y wget)

#echo "deb [arch=amd64] http://apt-mk.mirantis.com/$codename nightly  extra salt" > /etc/apt/sources.list.d/mcp_salt.list
echo "deb [arch=amd64] http://apt-mk.mirantis.com/$codename stable extra salt" > /etc/apt/sources.list.d/mcp_salt.list
wget -O - http://apt-mk.mirantis.com/public.gpg | apt-key add -

echo "deb http://repo.saltstack.com/apt/ubuntu/$version/amd64/2016.3 $codename main" > /etc/apt/sources.list.d/saltstack.list
wget -O - https://repo.saltstack.com/apt/ubuntu/$version/amd64/2016.3/SALTSTACK-GPG-KEY.pub | apt-key add -

apt-get clean
apt-get update
apt-get install -y salt-minion

echo "id: $node_name" >> /etc/salt/minion
echo "master: $config_host" >> /etc/salt/minion
rm -f /etc/salt/pki/minion/minion_master.pub
service salt-minion restart
echo "Showing node metadata..."
salt-call --no-color pillar.data
#echo "Running complete state ..."
#salt-call --no-color state.sls linux,openssh,salt -l info
