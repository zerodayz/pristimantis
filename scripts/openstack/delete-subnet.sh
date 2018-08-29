#!/bin/bash

set -x

ITEM_NAME="priv-subnet"

# Source the overcloudrc
source $HOME/overcloudrc

# Subnet delete
neutron subnet-delete $ITEM_NAME
