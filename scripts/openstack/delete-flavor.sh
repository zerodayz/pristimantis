#!/bin/bash

set -x

ITEM_NAME="m1.micro"

# Source the overcloudrc
source $HOME/overcloudrc

## Flavor
#
# Deletes the flavor
nova flavor-delete $ITEM_NAME
