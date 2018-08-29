#!/bin/bash

set -x

ITEM_NAME="cirros"
ITEM_LOCATION="$HOME/cirros-0.3.3-x86_64-disk.img"

# Source the overcloudrc
source $HOME/overcloudrc

## Images
#
# Upload image
image=$( glance image-list | grep "\s$ITEM_NAME[^.]" | awk '{ print $2 }')

if [ -z $image ]; then
  glance image-create --name $ITEM_NAME --disk-format qcow2 --container-format bare --file $ITEM_LOCATION
fi
