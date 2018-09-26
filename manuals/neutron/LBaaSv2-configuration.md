# LBaaSv2 Configuration

## Environment:

```
[root@undercloud-0 ~]# nova list
+--------------------------------------+--------------+--------+------------+-------------+------------------------+
| ID                                   | Name         | Status | Task State | Power State | Networks               |
+--------------------------------------+--------------+--------+------------+-------------+------------------------+
| 96300b08-99ff-4579-9a9b-ad2bff95902c | compute-0    | ACTIVE | -          | Running     | ctlplane=192.168.24.10 |
| 43dd79e4-1139-46d3-a52c-fbb0d05da3cf | controller-0 | ACTIVE | -          | Running     | ctlplane=192.168.24.9  |
| ff71e938-0b4e-43d5-9473-1b175baef65c | controller-1 | ACTIVE | -          | Running     | ctlplane=192.168.24.8  |
| c592cf7f-5a81-495a-8294-1c15fa8bd316 | controller-2 | ACTIVE | -          | Running     | ctlplane=192.168.24.7  |
+--------------------------------------+--------------+--------+------------+-------------+------------------------+
[root@undercloud-0 ~]# cat /etc/rhosp-release
Red Hat OpenStack Platform release 10.0 (Newton)

[root@undercloud-0 ~]# cat /etc/system-release
Red Hat Enterprise Linux Server release 7.5 (Maipo)

Reference: https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/10/html/networking_guide/sec-lbaas
```

## Configuration

```
[stack@undercloud-0 pristimantis]$ neutron agent-list | grep -i lbaas
[stack@undercloud-0 pristimantis]$ ansible-playbook tasks/configure_lbaas.yaml

PLAY [Install the LBaaS to Controller]

TASK [Gathering Facts]
ok: [controller-0]
ok: [controller-2]
ok: [controller-1]

TASK [Installs the openstack-neutron-lbaas package]
ok: [controller-1]
ok: [controller-2]
ok: [controller-0]

Continuing...
```

## Verification
