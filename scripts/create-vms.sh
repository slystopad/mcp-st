key="mcp_training"
image1=pub-ub14.04-64v2.copy
#image2=ubuntu-16-04-x64-mcp1.0.qcow2
image2=xenial
# m1.big2=1e407865-ba43-4a3f-9ca2-d59e44077edb
flavor_kvm=m1.big2

access_net_id=$(neutron net-show mcp-access --fields id -f value)
pxe_net_id=$(neutron net-show mcp-pxe --fields id -f value)
control_net_id=$(neutron net-show mcp-control --fields id -f value)
public_net_id=$(neutron net-show mcp-public --fields id -f value)
 
#nova boot --flavor 3 --image $image2 --nic net-id=$access_net_id --nic net-id=$pxe_net_id --key-name $key --security-groups allow_all salt-master2
#nova boot --flavor 3 --image $image2 --nic net-id=$access_net_id --nic net-id=$pxe_net_id --key-name $key --security-groups allow_all gitsrv


#nova boot --flavor 1e407865-ba43-4a3f-9ca2-d59e44077edb --image $image2 --nic net-id=$access_net_id --nic net-id=$pxe_net_id --nic net-id=$control_net_id --nic net-id=$public_net_id --key-name $key --security-groups allow_all kvm03.lab777.local

#nova boot --flavor 1e407865-ba43-4a3f-9ca2-d59e44077edb --image $image2 --nic net-id=$access_net_id --nic net-id=$pxe_net_id --nic net-id=$control_net_id --nic net-id=$public_net_id --key-name $key --security-groups allow_all --user-data ./user-data.yml kvm02.lab777.local

function get_port_id_by_name {
  local port_name=$1
  neutron port-show $1 -f value -c id
}

mk_user_data () {
  ## return generated user-data filename
  local fqdn=$1
  filename=$(mktemp)
cat > $filename << EOF
#cloud-config
#preserve_hostname: True
manage_etc_hosts: True
fqdn: ${fqdn}
hostname: ${fqdn}
EOF
echo $filename
}

function boot_vm {
local vm_name=$1
local filename=$(mk_user_data ${vm_name}.lab777.local)
#echo $filename
nova boot --flavor 1e407865-ba43-4a3f-9ca2-d59e44077edb --image $image2 \
 --nic port-id=$(get_port_id_by_name ${vm_name}-access-port) \
 --nic port-id=$(get_port_id_by_name ${vm_name}-pxe-port) \
 --nic port-id=$(get_port_id_by_name ${vm_name}-control-port) \
 --nic port-id=$(get_port_id_by_name ${vm_name}-public-port) \
 --key-name $key --security-groups allow_all --user-data $filename ${vm_name}.lab777.local
rm $filename
}

boot_kvm_node () {
  local kvm_node_name=$1
  local kvm_node_fixed_ip=$2
  echo "Creating ports"
  create_kvm_node_ports ${kvm_node_name} ${kvm_node_fixed_ip}
  echo "Starting VM"
  boot_vm ${kvm_node_name}
}

#nova boot --flavor 1e407865-ba43-4a3f-9ca2-d59e44077edb --image $image2 --nic net-id=$access_net_id --nic net-id=$pxe_net_id --nic net-id=$control_net_id --nic net-id=$public_net_id --key-name $key --security-groups allow_all kvm01
 
 
#get a list of vms:
# VMS=$(nova list|grep mcp-access|cut -d \| -f 2)
 
#for vm in $VMS; do
#   #echo getting VMs IPs
#   VMIPS=$(nova show $vm |grep "mcp-"|grep -v mcp-access|cut -d \| -f 3);
#   #echo disabling port.
#   for ip in $VMIPS; do
#     port=$(neutron port-list| grep $ip|cut -d \| -f 2)
#     echo "PORT>>> $port"
#     neutron  port-update  --port_security_enabled=False --no-allowed-address-pairs --no-security-groups $port
#   done
#done
