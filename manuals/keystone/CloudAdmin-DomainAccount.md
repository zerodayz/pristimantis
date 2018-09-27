## Domain Scope tokens

## Environment

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

## Configuration

First of all we need to get the `admin_token`

```
[root@controller-0 ~]# grep -i '^admin_token' /etc/keystone/keystone.conf
admin_token = hfr8trmMQ42JQGCmMkBmx23Pd
[root@controller-0 ~]#

[stack@undercloud-0 ~]$ openstack user list | grep "admin  "
| 68e60ceade4d433ba55889cb0bf12e6e | admin                   |
[stack@undercloud-0 ~]$ openstack role list | grep admin
| aaa3f9e2ce1c4195a76721cbcd4f439a | admin           |
```

Convert the user to be domain cloud admin (use previously found `user_id` and `role_id`)

```
[stack@undercloud-0 ~]$ curl -s -H "X-Auth-Token: hfr8trmMQ42JQGCmMkBmx23Pd" -X PUT http://10.0.0.103:5000/v3/domains/default/users/68e60ceade4d433ba55889cb0bf12e6e/roles/aaa3f9e2ce1c4195a76721cbcd4f439a

[root@controller-0 ~]# cp /etc/keystone/policy.json{,.backup}
[root@controller-0 ~]# ls -la /etc/keystone/policy.json*
-rw-r-----. 1 keystone keystone 9742 Jul 26  2017 /etc/keystone/policy.json
-rw-r-----. 1 root     root     9742 Sep 27 06:44 /etc/keystone/policy.json.backup
[root@controller-0 ~]#
```

To be able to use cloud admin we need to use `policy.v3cloudsample.json`

```
[root@controller-0 ~]# cp /usr/share/keystone/policy.v3cloudsample.json /etc/keystone/policy.json
cp: overwrite ‘/etc/keystone/policy.json’? yes
[root@controller-0 ~]# ls -la /etc/keystone/policy.json
-rw-r-----. 1 keystone keystone 13972 Sep 27 06:45 /etc/keystone/policy.json
[root@controller-0 ~]#
```

Swap the line in policy.json containing the default domain:

```
+    "cloud_admin": "role:admin and (token.is_admin_project:True or domain_id:default)",
-    "cloud_admin": "role:admin and (token.is_admin_project:True or domain_id:admin_domain_id)",
```

Also you need to make sure you will need to make changes to Horizon as well:

```
[root@controller-0 ~]# cp /etc/openstack-dashboard/keystone_policy.json{,.backup}
[root@controller-0 ~]# cp /etc/keystone/policy.json /etc/openstack-dashboard/keystone_policy.v3cloudsample.json
```
```
vi /etc/openstack-dashboard/local_settings

OPENSTACK_API_VERSIONS = { "identity": 3, }
OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True
OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = 'default'
OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3" % OPENSTACK_HOST

POLICY_FILES = {
#'identity': 'keystone_policy.json',
'identity': 'keystone_policy.v3cloudsample.json',
```

## Verify

### Domain scope token

```
curl -i -v -H "Content-type: application/json" -d'{"auth": {"identity": {"methods": ["password"], "password": {"user": {"domain": {"name": "default"}, "name": "admin", "password": "JqgwGDg6u2eVVhA8xKbyttyGn"}}}, "scope": {"domain": {"name": "default"}}}}' http://10.0.0.103:5000/v3/auth/tokens
```

### Project scope token

```
curl -i -v -H "Content-type: application/json" -d'{"auth": {"scope": {"project": {"domain": {"name": "Default"}, "name": "admin"}}, "identity": {"password": {"user": {"domain": {"name": "Default"}, "password": "JqgwGDg6u2eVVhA8xKbyttyGn", "name": "admin"}}, "methods": ["password"]}}}' http://10.0.0.103:5000/v3/auth/tokens
```
