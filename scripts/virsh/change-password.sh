#!/bin/bash

DOMAIN="control_0"
PASSWORD="redhat"

POOL=$( virsh dumpxml ${DOMAIN} | grep "pool=" | cut -d"=" -f2| cut -d"'" -f2 )
VOLUME=$( virsh dumpxml ${DOMAIN} | grep "volume=" | cut -d"=" -f3| cut -d"'" -f2 )
LOCATE=$( virsh vol-list oooq_pool | grep ${VOLUME} | awk '{print $2}' )

echo "Pool is ${POOL}"

echo "Volume is ${VOLUME}"

echo "Location is ${LOCATE}"

echo "Powering off the server ${DOMAIN}"
virsh destroy ${DOMAIN}

echo "Changing root password"
virt-customize --selinux-relabel -a ${LOCATE} --root-password password:${PASSWORD}

echo "Starting server ${DOMAIN}"
virsh start ${DOMAIN}

echo "Finished"
