# Containers-Tips-and-Tricks
# Docker

## Verify Checksum
Look at the ID and verify the one vs the one in
https://access.redhat.com/containers/#/registry.access.redhat.com/rhosp13/openstack-horizon/images/13.0-54

```
[root@controller-0 ~]# docker ps | grep horizon
88fbe479b31f        192.168.24.1:8787/rhosp13/openstack-horizon:2018-10-02.1                     "kolla_start"            17 hours ago        Up 17 hours                                   horizon
[root@controller-0 ~]# docker image ls| grep horizon
192.168.24.1:8787/rhosp13/openstack-horizon                     2018-10-02.1        89c267302245        6 weeks ago         811 MB
```

## Pull docker image and push to local
```
docker pull registry.access.redhat.com/openshift3/prometheus:v3.11.51-1
skopeo --tls-verify=false copy docker://registry.access.redhat.com/openshift3/prometheus:v3.11.51-1 docker://192.168.24.1:8787/openshift3/prometheus:v3.11.51-2
```
