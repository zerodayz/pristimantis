## Open vSwitch CLI

Reference: http://www.yet.org/2014/09/openvswitch-troubleshooting/

Before going any deeper with command line interface, you have to know that OVS does manage two kinds of flow:

    OpenFlows - User Space based
    Datapath - kernel based, a kind of cached version of the OpenFlow ones.

So different commands will be used to interact with each of them:

    ovs-ofctl - speak to OpenFlow module
    ovs-dpctl - speak to Kernel module

But lets start our cheatsheet with ovs-vsctl, an utility for querying and configuring ovs−vswitchd.

ovs-vsctl provides a high level interface for Open vSwitch Database. It allow you to query and configure ovs−vswitchd and is more convenient than ovsdb-* tools that are lower level commands.

```
ovs-vsctl –V version of openvswitch
ovs-vsctl show print a brief overview of database configuration
ovs-vsctl list-br list of configured bridges
ovs-vsctl list-ports <bridge> list of ports on a specific bridge
ovs-vsctl get-manager <bridge> list of NVP Controllers (TCP 6632)
ovs-vsctl get-controller <bridge> list of NVP Controllers (TCP 6633)
ovs-vsctl list manager list of NVP Controllers (TCP 6632)
ovs-vsctl list controller list of NVP Controllers (TCP 6633)
ovs-vsctl list interface list of interfaces
```

ovs-ofctl will allow you to monitor and administer OpenFlow switches.

```
ovs-ofctl dump-flows <br> Examine OpenFlow tables
ovs-ofctl show <br> port number to port name mapping
ovs-ofctl dump-ports <br> port statistics by port number
```

You can use watch like this

```
watch "ovs-ofctl dump-flows br-tun"
```

Note: read the man page of ovs-ofctl to better understand how to decode flow tables

```
ovs-appctl offer a way to send commands to a running Open vSwitch.
ovs-appctl bridge/dumpflows <br> examine flow tables, offers direct connectivity for VMs on the same hosts
ovs-appctl fdb/show <br> list mac/vlan pairs learned
ovs-dpctl can show, create, modify, and delete Open vSwitch datapaths.
ovs-dpctl dump-flows dump Datapath (kernel cached) flows
```

## OpenvSwitch tcpdump commands

Capture the packets on Open vSwitch interface and saves to pcap file

```
ovs-tcpdump -e -n -i <OpenvSwitch Interface> -w /tmp/$(hostname)-$(date +%F).pcap
```
