#### How to enable no-op driver in Ironic

url https://access.redhat.com/errata/RHBA-2018:3587

- [BZ - 1627043](https://bugzilla.redhat.com/show_bug.cgi?id=1627043) - Cisco UCS 200-M3 blades will not properly boot over the network from IPMI without skipping setting boot device with the IPMI driver

#### How to enable no-op driver in Ironic

This release introduces a new `noop` management interface for the `ipmi` driver.

Make sure that`ironic.conf` 

- Contains `ipmi` in `enabled_hardware_types`

- Contains `noop` in `enabled_management_interfaces`

```
[DEFAULT]
enabled_hardware_types = redfish,ipmi,idrac,ilo
enabled_management_interfaces = idrac,ipmitool,ilo,noop,fake,redfish
enabled_power_interfaces = redfish,ilo,idrac,ipmitool,fake
```

- Restart Ironic services:
  
  ```
  systemctl restart openstack-ironic-api.service
  systemctl restart openstack-ironic-inspector-dnsmasq
  systemctl restart openstack-ironic-conductor.service
  systemctl restart openstack-ironic-inspector.service
  ```

- Change the node to use the `noop` management interface:
  
  ```
  openstack baremetal node set $NODE --management-interface noop
  ```

Here is an example:

```bash
(undercloud) [root@undercloud-0 ~]# ironic node-show e80d3ff2-6fd9-4927-bd6b-43aab79260b8 | egrep "power_interface|management_interface|raid_interface|vendor_interface|driver_interface|driver"                                            
    The "ironic" CLI is deprecated and will be removed in the S* release. Please use the "openstack baremetal" CLI instead.
    | driver                 | ipmi                                                                     |
    | driver_info            | {u'ipmi_port': u'6233', u'ipmi_username': u'admin', u'deploy_kernel':    |
    | driver_internal_info   | {u'agent_url': u'http://192.168.24.19:9999', u'root_uuid_or_disk_id':    |
    | management_interface   | noop                                                                     |
    | power_interface        | ipmitool                                                                 |
    | raid_interface         | no-raid                                                                  |
    | vendor_interface       | ipmitool                                                                 |

```


