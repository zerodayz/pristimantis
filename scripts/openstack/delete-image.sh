#!/bin/bash

set -x

ITEM_NAME="cirros"

# Source the overcloudrc
source $HOME/overcloudrc

# Delete image
image=$( glance image-list | grep $ITEM_NAME | awk '{print $2}' )
glance image-delete $image

