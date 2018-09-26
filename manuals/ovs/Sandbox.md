## Setup Sandbox Open vSwitch

```
git clone https://github.com/openvswitch/ovs.git
cd ovs
./boot.sh
./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc
make && make sandbox

Continuation...

----------------------------------------------------------------------
You are running in a dummy Open vSwitch environment.  You can use
ovs-vsctl, ovs-ofctl, ovs-appctl, and other tools to work with the
dummy switch.
```

## Verify sandbox

```
ovs-vsctl add-br br0 -- set Bridge br0 fail-mode=secure
```

In addition to adding a port, the ovs-vsctl command above sets its "ofport_request" column to ensure that port p1 is assigned OpenFlow port 1, p2 is assigned OpenFlow port 2, and so on.

```
for i in 1 2 3 4; do
    ovs-vsctl add-port br0 p$i -- set Interface p$i ofport_request=$i
      ovs-ofctl mod-port br0 p$i up
done
```

The ovs-ofctl command above brings up the simulated interfaces, which are down initially, using an OpenFlow request. The effect is similar to ifconfig up, but the sandbox's interfaces are not visible to the operating system and therefore ifconfig would not affect them.

```
ovs-vsctl show
6a85bf29-9c8d-4910-b4bc-29fc797dc4cb
   Bridge "br0"
       fail_mode: secure
       Port "br0"
           Interface "br0"
               type: internal
       Port "p4"
           Interface "p4"
       Port "p2"
           Interface "p2"
       Port "p3"
           Interface "p3"
       Port "p1"
           Interface "p1"
```

## Quitting Open vSwitch sandbox

```
exit
```
