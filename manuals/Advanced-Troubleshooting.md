# Advanced Troubleshooting

This is idea behind the Advanced Troubleshooting

# Enable Debug
Always check that debug is enabled in configuration file.

With crudini:

Note: You need to install package `crudini`

```
[root@undercloud-0 ~]# crudini --get  /etc/nova/nova.conf DEFAULT debug
True
```

With g/re/p:

```
[root@undercloud-0 ~]# egrep "^\[.*\]|^(debug|\#debug)" /etc/nova/nova.conf
[DEFAULT]
#debug=false
debug=True
[api_database]
[barbican]
[cache]
```
# Date
Always check date if the cluster is synced with NTP.
# Agent health
Check if any of the services/agents is reported as down

```
nova service-list
cinder service-list
neutron agent-list
heat service-list
```

Open configuration for the service which the agent/service shows as down.

```report_interval :``` status report interval, ie heartbeat interval, defaults to 10 seconds.

```service_down_time :``` the longest time from the last heartbeat,  if it takes more than this time to get a heartbeat, then the service is down, the default is 60 seconds.

Note: *```report_interval``` must be less than ```service_down_time```, otherwise you send a heartbeat each 60 seconds, and since agent is 30 seconds without heartbeat it will think that the service down, obviously the service will always be in the down state.*

 ## Possible root causes:

1. Database access errors leads to heartbeat update failure, this situation can be seen from the error log.

2. RabbitMQ connection failure, nova-compute can not directly access the database, the update is done through the RPC call nova-conductor, if the RabbitMQ connection fails, RPC will not be able to perform, resulting in heartbeat transmission failure.

3. nova-conductor failure, the same reason, but this situation is very low probability, unless the someone closed the service.

4. Time is not synchronized. This is very difficult to check this situation, because you can not find any error message in the log.

Possible replacement?

https://wiki.openstack.org/wiki/NovaZooKeeperHeartbeat
# Bugfix
How to check if the bug https://bugs.launchpad.net/neutron/+bug/1187102 has been fixed in `openstack-neutron-2014.2.3-9.el7ost.noarch` ?

The bug contains commits: `['c7e533c3679a1f4a612f3b53354cb7cb5bc1ba12', '1d776bc16c033f33e61fd6832f2e94e24cdd1c5f', 'b049971c5652adc8e6146f15180ceccc58f8ae9a']`

To check what tag contains commit:

```
🎩 ➜  neutron git:(2a9844b8ca) git tag --contains c7e533c3679a1f4a612f3b53354cb7cb5bc1ba12 | head     
10.0.0
10.0.0.0b1
10.0.0.0b2
10.0.0.0b3
10.0.0.0rc1
10.0.0.0rc2
10.0.1
10.0.2
10.0.3
10.0.4
```
