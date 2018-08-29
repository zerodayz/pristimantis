#!/bin/bash

set -x

ITEM_NAME="default"

# Source the overcloudrc
source $HOME/overcloudrc

## Networking
#

neutron net-delete $ITEM_NAME
