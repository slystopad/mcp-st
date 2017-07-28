#!/bin/bash -x
neutron router-create pub01
neutron router-gateway-set pub01 admin_floating_net
neutron router-interface-add pub01 mcp-access-subnet
