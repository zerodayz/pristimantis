#!/bin/bash

set -x

ITEM_NAME="priv-subnet"
ITEM_NETWORK="default"
ITEM_CIDR="192.168.1.0/24"

# Source the overcloudrc
source $HOME/overcloudrc

# Subnet create
subnet=$( neutron subnet-list | grep "\s$ITEM_NAME[^.]" | awk '{ print $2 }')

if [ -z $subnet ]; then
  neutron subnet-create --name $ITEM_NAME --enable-dhcp $ITEM_NETWORK $ITEM_CIDR
fi
