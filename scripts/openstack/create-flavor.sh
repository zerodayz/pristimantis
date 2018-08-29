#!/bin/bash

set -x

ITEM_NAME="m1.micro"
ITEM_ID="auto"
ITEM_RAM="256"
ITEM_DISK="1"
ITEM_VCPU="1"

# Source the overcloudrc
source $HOME/overcloudrc

## Flavor
#
# Creates the flavor
flavor=$( nova flavor-list | grep "\s$ITEM_NAME[^.]" | awk '{ print $2 }')

if [ -z $flavor ]; then
  nova flavor-create $ITEM_NAME $ITEM_ID $ITEM_RAM $ITEM_DISK $ITEM_VCPU
fi

