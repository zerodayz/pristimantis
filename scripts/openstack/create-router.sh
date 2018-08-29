#!/bin/bash

set -x

ITEM_NAME="default-router"

# Source the overcloudrc
source $HOME/overcloudrc

# Router Create
router=$( neutron router-list | grep "\s$ITEM_NAME[^.]" | awk '{ print $2 }')

if [ -z $router ]; then
  neutron router-create $ITEM_NAME
fi
