## LBaaSv2 UI

Install required packages

```
# yum install openstack-neutron-lbaas-ui
```

Enable LBaaS UI

```
# vim /etc/openstack-dashboard/local_settings

OPENSTACK_NEUTRON_NETWORK = {
    'enable_distributed_router': False,
    'enable_firewall': False,
    'enable_ha_router': False,
    'enable_lb': True,
    'enable_quotas': True,
    'enable_security_group': True,
    'enable_vpn': False,
    'profile_support': None,
}
```

Restart Horizon

```
# systemctl restart httpd
```
