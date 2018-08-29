#!/bin/bash

set -x

ITEM_NAME="dummy-instance-01"
ITEM_IMAGE="cirros"
ITEM_FLAVOR="m1.micro"
ITEM_NETWORK="default"

# Source the overcloudrc
source $HOME/overcloudrc

## Assign the network
#
network=$( neutron net-list | grep $ITEM_NETWORK | awk '{ print $2 }')

# Boot instance 
nova boot --flavor $ITEM_FLAVOR --image $ITEM_IMAGE --nic net-id=$network $ITEM_NAME 
