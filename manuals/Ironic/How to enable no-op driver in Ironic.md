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
  openstack baremetal node set  --management-interface noop
  ```
