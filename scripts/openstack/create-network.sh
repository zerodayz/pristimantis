#!/bin/bash

set -x

ITEM_NAME="default"

# Source the overcloudrc
source $HOME/overcloudrc

## Networking
#
network=$( neutron net-list | grep "\s$ITEM_NAME[^.]" | awk '{ print $2 }')

if [ -z $network ]; then
  neutron net-create $ITEM_NAME
fi
