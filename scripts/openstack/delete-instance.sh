#!/bin/bash

set -x

ITEM_NAME="dummy-instance-01"

# Source the overcloudrc
source $HOME/overcloudrc

# Delete instance 
nova delete $ITEM_NAME
