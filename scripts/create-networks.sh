#!/bin/bash -x
[[ "${BASH_SOURCE[0]}" != "${0}" ]] && echo "script ${BASH_SOURCE[0]} is being sourced ..."
#mcp-access-addr='192.168.200.0/24'
#mcp-pxe-addr='192.168.201.0/24'
#mcp-control-addr='192.168.203.0/24'
#mcp-public-addr='192.168.202.0/24'
MCP_NETWORKS_SET='access pxe control public'
mcp_access_addr='192.168.83.0/24'
mcp_pxe_addr='192.168.80.0/24'
mcp_control_addr='192.168.81.0/24'
mcp_public_addr='192.168.82.0/24'

function get_subnet_id_by_name {
  local subnet_name=$1
  neutron subnet-show -f value -c id $subnet_name
}

function get_server_id_by_name {
  local server_name=$1
  openstack server show -f value $server_name -c id
}

## get subnet id for list of subnets and
## set put it in variable in form mcp_${subnet}_subnet_id
for subnet in $MCP_NETWORKS_SET; do
  eval mcp_${subnet}_subnet_id=$(get_subnet_id_by_name mcp-${subnet}-subnet)
done

function create_networks () {
echo "Creating MCP networks"
return 0

neutron net-create mcp-access
neutron subnet-create --name mcp-access-subnet --dns-nameserver 8.8.8.8 --dns-nameserver 172.18.80.136 mcp-access $mcp_access_addr
 
neutron net-create mcp-pxe
neutron subnet-create --name mcp-pxe-subnet --disable-dhcp --no-gateway mcp-pxe $mcp_pxe_addr
 
neutron net-create mcp-control
neutron subnet-create --no-gateway --disable-dhcp --name mcp-control-subnet mcp-control $mcp_control_addr
 
neutron net-create mcp-public
neutron subnet-create --name mcp-public-subnet --disable-dhcp mcp-public $mcp_public_addr
 
 
nova secgroup-create allow_all "allow all traffic"
nova secgroup-add-rule allow_all ICMP -1 -1 0.0.0.0/0
nova secgroup-add-rule allow_all TCP 1 65535 0.0.0.0/0    
nova secgroup-add-rule allow_all UDP 1 65535 0.0.0.0/0 
}

function create_port_in_subnet {
  # create_port_in_subnet <portname> <subnet_name> [fixed_ip]
  local portname=$1
  local subnet_name=$2
  local fixed_ip=$3

  local net_id=$(neutron subnet-show ${subnet_name} -f value -c network_id)
  local subnet_id=$(neutron subnet-show ${subnet_name} -f value -c id)
  if [[ -z "$fixed_ip" ]]; then
    neutron port-create ${net_id} --name ${portname} -f value -c id | tail -1
  else
    neutron port-create ${net_id} --name ${portname} --fixed-ip subnet_id=${subnet_id},ip_address=${fixed_ip} -f value -c id | tail -1
  fi
}

function create_kvm_node_ports {
  local kvm_node_name=$1
  local fixed_ip=$2 # last octet in dec representation
  for n in $MCP_NETWORKS_SET; do
    if [[ -z "$fixed_ip" ]]; then
      new_port_id=$(create_port_in_subnet ${kvm_node_name}-${n}-port mcp-${n}-subnet)
    else
      subnet_cidr=$(neutron subnet-show mcp-${n}-subnet -f value -c cidr)
      # TODO: fix to work with any CIDR
      fixed_ip_prefix=${subnet_cidr%'.0/24'}
      new_port_id=$(create_port_in_subnet ${kvm_node_name}-${n}-port mcp-${n}-subnet ${fixed_ip_prefix}.${fixed_ip})
    fi
    port_disable_security $new_port_id
  done
}

function port_disable_security {
  local port_id=$1
  neutron port-update --port_security_enabled=False --no-allowed-address-pairs --no-security-groups ${port_id}
}

function delete_kvm_node_ports {
  local kvm_node_name=$1
  for n in $MCP_NETWORKS_SET; do
    neutron port-delete ${kvm_node_name}-${n}-port
  done
}

## no sourced so run main flow
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "Being executed ..."
  create_networks
fi
