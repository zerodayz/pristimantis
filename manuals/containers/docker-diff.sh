#!/usr/bin/env bash

docker run registry.access.redhat.com/rhosp13/openstack-neutron-dhcp-agent:13.0-64 bash -c 'cat /usr/lib/python2.7/site-packages/neutron/agent/linux/dhcp.py' > a
docker run registry.access.redhat.com/rhosp13/openstack-neutron-dhcp-agent:latest bash -c 'cat /usr/lib/python2.7/site-packages/neutron/agent/linux/dhcp.py' > b
diff -u a b
