# LBaaSv2 Configuration

Reference: https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/10/html/networking_guide/sec-lbaas

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
```

## Before

```
[stack@undercloud-0 pristimantis]$ source ~stack/overcloudrc
[stack@undercloud-0 pristimantis]$ neutron agent-list | grep -i lbaas
[stack@undercloud-0 pristimantis]$
```

## Configuration

```
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

PLAY RECAP
controller-0               : ok=22   changed=10   unreachable=0    failed=0
controller-1               : ok=20   changed=9    unreachable=0    failed=0
controller-2               : ok=20   changed=9    unreachable=0    failed=0

```

## After

```
[stack@undercloud-0 pristimantis]$ source ~stack/overcloudrc
[stack@undercloud-0 pristimantis]$ neutron agent-list | grep -i lbaas
| 925a55c4-3c28-4569-9684-f4f2e5564a70 | Loadbalancerv2 agent | controller-0.localdomain |                   | :-)   | True           | neutron-lbaasv2-agent     |
| dd4f7a24-0234-484f-b79d-21493eb961a7 | Loadbalancerv2 agent | controller-2.localdomain |                   | :-)   | True           | neutron-lbaasv2-agent     |
| e3413be8-ad3e-4336-a701-d3be0b4d0e3b | Loadbalancerv2 agent | controller-1.localdomain |                   | :-)   | True           | neutron-lbaasv2-agent     |
```

## Testing LBaaSv2

```
[stack@undercloud-0 openstack]$ nova list
+--------------------------------------+-------------------+--------+------------+-------------+----------------------+
| ID                                   | Name              | Status | Task State | Power State | Networks             |
+--------------------------------------+-------------------+--------+------------+-------------+----------------------+
| 945dd0e3-1488-4b39-ada3-03fd6f40443d | dummy-instance-01 | ACTIVE | -          | Running     | default=192.168.1.12 |
| 60be67e0-a009-464b-8ed6-73e7d1fd8f9a | dummy-instance-02 | ACTIVE | -          | Running     | default=192.168.1.8  |
+--------------------------------------+-------------------+--------+------------+-------------+----------------------+
[stack@undercloud-0 openstack]$ neutron subnet-list
+--------------------------------------+---------------------------------------------------+------------------+------------------------------------------------------+
| id                                   | name                                              | cidr             | allocation_pools                                     |
+--------------------------------------+---------------------------------------------------+------------------+------------------------------------------------------+
| 62b73dd3-7355-4829-97a4-c9ed9c65b647 | external_subnet                                   | 10.0.0.0/24      | {"start": "10.0.0.210", "end": "10.0.0.250"}         |
| eac25d28-e6fa-4d9c-bd29-b9b7e6507405 | HA subnet tenant a09a48f113ba4e30b134fdbf93adb6d6 | 169.254.192.0/18 | {"start": "169.254.192.1", "end": "169.254.255.254"} |
| edeb5e06-7193-4081-8da9-3460f504d9bd | priv-subnet                                       | 192.168.1.0/24   | {"start": "192.168.1.2", "end": "192.168.1.254"}     |
+--------------------------------------+---------------------------------------------------+------------------+------------------------------------------------------+
```

## Create LBaaSV2

```
neutron lbaas-loadbalancer-create --name first_lb1 priv-subnet
neutron lbaas-listener-create --loadbalancer first_lb1 --protocol HTTP --protocol-port 80 --name listener1
neutron lbaas-pool-create --lb-algorithm ROUND_ROBIN --listener listener1 --protocol HTTP --name POOL1
neutron lbaas-member-create --subnet priv-subnet --address 192.168.1.12 --protocol-port 80 POOL1
neutron lbaas-member-create --subnet priv-subnet --address 192.168.1.8 --protocol-port 80 POOL1

[stack@undercloud-0 openstack]$ neutron lbaas-loadbalancer-list
+--------------------------------------+-----------+--------------+---------------------+----------+
| id                                   | name      | vip_address  | provisioning_status | provider |
+--------------------------------------+-----------+--------------+---------------------+----------+
| 94a38e69-9071-4df6-bd31-1c5eb06af7e5 | first_lb1 | 192.168.1.13 | ACTIVE              | haproxy  |
+--------------------------------------+-----------+--------------+---------------------+----------+

```

- Start webserver on dummy-instance-01 and dummy-instance-02

## Verification

```
[root@controller-2 ~]# while true; do curl 192.168.1.13; sleep 1; echo; done
dummy-instance-02
dummy-instance-01
dummy-instance-02
dummy-instance-01
dummy-instance-02
dummy-instance-01
dummy-instance-02
dummy-instance-01
dummy-instance-02
dummy-instance-01
dummy-instance-02
dummy-instance-01
dummy-instance-02
dummy-instance-01
dummy-instance-02
dummy-instance-01
dummy-instance-02
dummy-instance-01
dummy-instance-02
dummy-instance-01
dummy-instance-02
dummy-instance-01
dummy-instance-02
dummy-instance-01
```
