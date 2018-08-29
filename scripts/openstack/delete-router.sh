#!/bin/bash

set -x

ITEM_NAME="default-router"

# Source the overcloudrc
source $HOME/overcloudrc

# Router Create
neutron router-delete $ITEM_NAME 
