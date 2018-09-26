## Tracing packets

## Setup Sandbox environment

From [Sandbox](Sandbox.md)

## Tracing packets with ovs-appctl on br0

```
ovs-ofctl dump-ports-desc br0
OFPST_PORT_DESC reply (xid=0x2):
 1(p1): addr:aa:55:aa:55:00:22
     config:     0
     state:      0
     speed: 0 Mbps now, 0 Mbps max
 2(p2): addr:aa:55:aa:55:00:23
     config:     0
     state:      0
     speed: 0 Mbps now, 0 Mbps max
 3(p3): addr:aa:55:aa:55:00:24
     config:     0
     state:      0
     speed: 0 Mbps now, 0 Mbps max
 4(p4): addr:aa:55:aa:55:00:25
     config:     0
     state:      0
     speed: 0 Mbps now, 0 Mbps max
 LOCAL(br0): addr:16:b8:3d:4d:17:48
     config:     PORT_DOWN
     state:      LINK_DOWN
     speed: 0 Mbps now, 0 Mbps max
```

## Tracing Table 0

```
ovs-ofctl dump-flows br0 table=0
 cookie=0x0, duration=20.175s, table=0, n_packets=0, n_bytes=0, dl_src=01:00:00:00:00:00/01:00:00:00:00:00 actions=drop
 cookie=0x0, duration=14.976s, table=0, n_packets=0, n_bytes=0, dl_dst=01:80:c2:00:00:00/ff:ff:ff:ff:ff:f0 actions=drop
 cookie=0x0, duration=4.663s, table=0, n_packets=0, n_bytes=0, priority=0 actions=resubmit(,1)
```

We simulate submitting the packets to br0 Bridge on port 1

```
ovs-appctl ofproto/trace br0 in_port=1,dl_dst=01:80:c2:00:00:05
Flow: in_port=1,vlan_tci=0x0000,dl_src=00:00:00:00:00:00,dl_dst=01:80:c2:00:00:05,dl_type=0x0000

bridge("br0")
-------------
 0. dl_dst=01:80:c2:00:00:00/ff:ff:ff:ff:ff:f0, priority 32768
    drop

Final flow: unchanged
Megaflow: recirc_id=0,eth,in_port=1,dl_src=00:00:00:00:00:00/01:00:00:00:00:00,dl_dst=01:80:c2:00:00:00/ff:ff:ff:ff:ff:f0,dl_type=0x0000
Datapath actions: drop
```

The following packet with destination MAC address `01:80:c2:00:00:05` would be dropped because of rule

```
bridge("br0")
-------------
 0. dl_dst=01:80:c2:00:00:00/ff:ff:ff:ff:ff:f0, priority 32768
    drop
```

`f` Match exactly the bit in the MAC address
`0` Can be any bit in the MAC address.

The reason is that with mask of `ff:ff:ff:ff:ff:f0` the MAC `01:80:c2:00:00:0<any bit here>` and the rule matches `actions=drop`  

If we slightly modify the MAC address to `02:80:c2:00:00:05` we hit the other rule

```
ovs-appctl ofproto/trace br0 in_port=1,dl_dst=02:80:c2:00:00:05
Flow: in_port=1,vlan_tci=0x0000,dl_src=00:00:00:00:00:00,dl_dst=02:80:c2:00:00:05,dl_type=0x0000

bridge("br0")
-------------
 0. priority 0
    resubmit(,1)
 1. No match.
    drop

Final flow: unchanged
Megaflow: recirc_id=0,eth,in_port=1,dl_src=00:00:00:00:00:00/01:00:00:00:00:00,dl_dst=02:80:c2:00:00:00/ff:ff:ff:ff:ff:f0,dl_type=0x0000
Datapath actions: drop
```

The rules that matches this packet would be

```
bridge("br0")
-------------
 0. priority 0
    resubmit(,1)
 1. No match.
    drop
```

This time it doesn't match any of our `actions=drop` rules. so it falls into `0.` which is `resubmit(,1)` this causes second lookup `1.` in table 1 which have no flow, so the packet is actually still dropped.

## Tracing Table 1

We simulate submitting the packets to br0 Bridge

The output shows the lookup in table 0, the resubmit to table 1, and the resubmit to table 2 (which does nothing because we haven't put anything there yet)

```
ovs-appctl ofproto/trace br0 in_port=1,vlan_tci=5
Flow: in_port=1,vlan_tci=0x0005,vlan_tci1=0x0000,dl_src=00:00:00:00:00:00,dl_dst=00:00:00:00:00:00,dl_type=0x0000

bridge("br0")
-------------
 0. priority 0
    resubmit(,1)
 1. in_port=1, priority 99
    resubmit(,2)
 2. No match.
    drop

Final flow: unchanged
Megaflow: recirc_id=0,eth,in_port=1,dl_src=00:00:00:00:00:00/01:00:00:00:00:00,dl_dst=00:00:00:00:00:00/ff:ff:ff:ff:ff:f0,dl_type=0x0000
Datapath actions: drop
```

The output is similar to that for the previous case, except that it additionally tags the packet with p2's VLAN 20 before it passes it along to table 2

```
ovs-appctl ofproto/trace br0 in_port=2
Flow: in_port=2,vlan_tci=0x0000,dl_src=00:00:00:00:00:00,dl_dst=00:00:00:00:00:00,dl_type=0x0000

bridge("br0")
-------------
 0. priority 0
    resubmit(,1)
 1. in_port=2,vlan_tci=0x0000, priority 99
    mod_vlan_vid:20
    resubmit(,2)
 2. No match.
    drop

Final flow: in_port=2,dl_vlan=20,dl_vlan_pcp=0,vlan_tci1=0x0000,dl_src=00:00:00:00:00:00,dl_dst=00:00:00:00:00:00,dl_type=0x0000
Megaflow: recirc_id=0,eth,in_port=2,vlan_tci=0x0000,dl_src=00:00:00:00:00:00/01:00:00:00:00:00,dl_dst=00:00:00:00:00:00/ff:ff:ff:ff:ff:f0,dl_type=0x0000
Datapath actions: drop
```

This tests an invalid packet (one that includes an 802.1Q header) coming in on access port p2

```
ovs-appctl ofproto/trace br0 in_port=2,vlan_tci=5
Flow: in_port=2,vlan_tci=0x0005,vlan_tci1=0x0000,dl_src=00:00:00:00:00:00,dl_dst=00:00:00:00:00:00,dl_type=0x0000

bridge("br0")
-------------
 0. priority 0
    resubmit(,1)
 1. priority 0
    drop

Final flow: unchanged
Megaflow: recirc_id=0,eth,in_port=2,vlan_tci=0x0005,dl_src=00:00:00:00:00:00/01:00:00:00:00:00,dl_dst=00:00:00:00:00:00/ff:ff:ff:ff:ff:f0,dl_type=0x0000
Datapath actions: drop
```

This drops the packet because it has VLAN header. If you check the dump-flows you will see that only packets without VLAN header are re-submitted to table 2 anything else is dropped.

```
cookie=0x0, duration=16.058s, table=1, n_packets=0, n_bytes=0, priority=99,in_port=p2,vlan_tci=0x0000 actions=mod_vlan_vid:20,resubmit(,2)
```

## Tracing Table 2

We simulate submitting the packets to br0 Bridge

This shows the packet was re-submitted to table 3 which we have not yet implemented, but it is being learnt in table 10. The `-generate` keyword is new. Ordinarily, `ofproto/trace` has no side effects: "output" actions do not actually output packets, "learn" actions do not actually modify the flow table, and so on.  
With `-generate`, though, `ofproto/trace` does execute "learn" actions. That's important now, because we want to see the effect of the "learn" action on table 10. You can see that by running:

```
ovs-appctl ofproto/trace br0 in_port=1,vlan_tci=20,dl_src=50:00:00:00:00:01 -generate

Flow: in_port=1,vlan_tci=0x0014,vlan_tci1=0x0000,dl_src=50:00:00:00:00:01,dl_dst=00:00:00:00:00:00,dl_type=0x0000

bridge("br0")
-------------
 0. priority 0
    resubmit(,1)
 1. in_port=1, priority 99
    resubmit(,2)
 2. priority 32768
    learn(table=10,NXM_OF_VLAN_TCI[0..11],NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[],load:NXM_OF_IN_PORT[]->NXM_NX_REG0[0..15])
     -> table=10 vlan_tci=0x0014/0x0fff,dl_dst=50:00:00:00:00:01 priority=32768 actions=load:0x1->NXM_NX_REG0[0..15]
    resubmit(,3)
 3. No match.
    drop

Final flow: unchanged
Megaflow: recirc_id=0,eth,in_port=1,vlan_tci=0x0014/0x1fff,dl_src=50:00:00:00:00:01,dl_dst=00:00:00:00:00:00/ff:ff:ff:ff:ff:f0,dl_type=0x0000
Datapath actions: drop

```
You can see that the packet coming in on VLAN 20 with source `MAC 50:00:00:00:00:01` became a flow that matches `VLAN 20` (`vlan_tci=0x0014`) and destination MAC `50:00:00:00:00:01`  (`dl_dst=50:00:00:00:00:01`). The flow loads port number 1, the input port for the flow we tested, into register 0.

```
ovs-ofctl dump-flows br0 table=10
 cookie=0x0, duration=165.765s, table=10, n_packets=0, n_bytes=0, vlan_tci=0x0014/0x0fff,dl_dst=50:00:00:00:00:01 actions=load:0x1->NXM_NX_REG0[0..15]
```

Now we can try re-learn the port for source MAC address

```
ovs-appctl ofproto/trace br0 in_port=2,dl_src=50:00:00:00:00:01 -generate
Flow: in_port=2,vlan_tci=0x0000,dl_src=50:00:00:00:00:01,dl_dst=00:00:00:00:00:00,dl_type=0x0000

bridge("br0")
-------------
 0. priority 0
    resubmit(,1)
 1. in_port=2,vlan_tci=0x0000, priority 99
    mod_vlan_vid:20
    resubmit(,2)
 2. priority 32768
    learn(table=10,NXM_OF_VLAN_TCI[0..11],NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[],load:NXM_OF_IN_PORT[]->NXM_NX_REG0[0..15])
     -> table=10 vlan_tci=0x0014/0x0fff,dl_dst=50:00:00:00:00:01 priority=32768 actions=load:0x2->NXM_NX_REG0[0..15]
    resubmit(,3)
 3. No match.
    drop

Final flow: in_port=2,dl_vlan=20,dl_vlan_pcp=0,vlan_tci1=0x0000,dl_src=50:00:00:00:00:01,dl_dst=00:00:00:00:00:00,dl_type=0x0000
Megaflow: recirc_id=0,eth,in_port=2,vlan_tci=0x0000,dl_src=50:00:00:00:00:01,dl_dst=00:00:00:00:00:00/ff:ff:ff:ff:ff:f0,dl_type=0x0000
Datapath actions: drop
```

Then we see that the flow we saw previously has changed to indicate that the learned port is port 2, as we would expect

```
ovs-ofctl dump-flows br0 table=10                                        
 cookie=0x0, duration=291.671s, table=10, n_packets=0, n_bytes=0, vlan_tci=0x0014/0x0fff,dl_dst=50:00:00:00:00:01 actions=load:0x2->NXM_NX_REG0[0..15]
```

## Tracing Table 3

We simulate submitting the packets to br0 Bridge

Here's a command that should cause OVS to learn that f0:00:00:00:00:01 is on p1 in VLAN 20:

```
ovs-appctl ofproto/trace br0 in_port=1,dl_vlan=20,dl_src=f0:00:00:00:00:01,dl_dst=90:00:00:00:00:01 -generate
Flow: in_port=1,dl_vlan=20,dl_vlan_pcp=0,vlan_tci1=0x0000,dl_src=f0:00:00:00:00:01,dl_dst=90:00:00:00:00:01,dl_type=0x0000

bridge("br0")
-------------
 0. priority 0
    resubmit(,1)
 1. in_port=1, priority 99
    resubmit(,2)
 2. priority 32768
    learn(table=10,NXM_OF_VLAN_TCI[0..11],NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[],load:NXM_OF_IN_PORT[]->NXM_NX_REG0[0..15])
     -> table=10 vlan_tci=0x0014/0x0fff,dl_dst=f0:00:00:00:00:01 priority=32768 actions=load:0x1->NXM_NX_REG0[0..15]
    resubmit(,3)
 3. priority 50
    resubmit(,10)
    10. No match.
            drop
    resubmit(,4)
 4. No match.
    drop

Final flow: unchanged
Megaflow: recirc_id=0,eth,in_port=1,dl_vlan=20,dl_src=f0:00:00:00:00:01,dl_dst=90:00:00:00:00:01,dl_type=0x0000
Datapath actions: drop
```

We have so far learned that `50:00:00:00:00:01` is on port `2` and `f0:00:00:00:00:01` in port `1` both VLAN 20
```
ovs-ofctl dump-flows br0 table=10
 cookie=0x0, duration=1179.020s, table=10, n_packets=0, n_bytes=0, vlan_tci=0x0014/0x0fff,dl_dst=50:00:00:00:00:01 actions=load:0x2->NXM_NX_REG0[0..15]
 cookie=0x0, duration=301.550s, table=10, n_packets=0, n_bytes=0, vlan_tci=0x0014/0x0fff,dl_dst=f0:00:00:00:00:01 actions=load:0x1->NXM_NX_REG0[0..15]
```

## Tracing Table 4

We simulate submitting the packets to br0 Bridge

Try tracing a broadcast packet arriving on p1 in VLAN 30:

```
ovs-appctl ofproto/trace br0 in_port=1,dl_dst=ff:ff:ff:ff:ff:ff,dl_vlan=30
Flow: in_port=1,dl_vlan=30,dl_vlan_pcp=0,vlan_tci1=0x0000,dl_src=00:00:00:00:00:00,dl_dst=ff:ff:ff:ff:ff:ff,dl_type=0x0000

bridge("br0")
-------------
 0. priority 0
    resubmit(,1)
 1. in_port=1, priority 99
    resubmit(,2)
 2. priority 32768
    learn(table=10,NXM_OF_VLAN_TCI[0..11],NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[],load:NXM_OF_IN_PORT[]->NXM_NX_REG0[0..15])
     >> suppressing side effects, so learn action ignored
    resubmit(,3)
 3. priority 50
    resubmit(,10)
    10. No match.
            drop
    resubmit(,4)
 4. reg0=0,dl_vlan=30, priority 99
    output:1
     >> skipping output to input port
    strip_vlan
    output:3
    output:4

Final flow: in_port=1,vlan_tci=0x0000,dl_src=00:00:00:00:00:00,dl_dst=ff:ff:ff:ff:ff:ff,dl_type=0x0000
Megaflow: recirc_id=0,eth,in_port=1,dl_vlan=30,dl_vlan_pcp=0,dl_src=00:00:00:00:00:00,dl_dst=ff:ff:ff:ff:ff:ff,dl_type=0x0000
Datapath actions: pop_vlan,3,4
```

The interesting part of the output is the final line, which shows that the switch would remove the 802.1Q header and then output the packet to p3 and p4, which are access ports for VLAN 30:

```
Datapath actions: pop_vlan,3,4
```

Similarly, if we trace a broadcast packet arriving on p3:

```
ovs-appctl ofproto/trace br0 in_port=3,dl_dst=ff:ff:ff:ff:ff:ff
Flow: in_port=3,vlan_tci=0x0000,dl_src=00:00:00:00:00:00,dl_dst=ff:ff:ff:ff:ff:ff,dl_type=0x0000

bridge("br0")
-------------
 0. priority 0
    resubmit(,1)
 1. in_port=3,vlan_tci=0x0000, priority 99
    mod_vlan_vid:30
    resubmit(,2)
 2. priority 32768
    learn(table=10,NXM_OF_VLAN_TCI[0..11],NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[],load:NXM_OF_IN_PORT[]->NXM_NX_REG0[0..15])
     >> suppressing side effects, so learn action ignored
    resubmit(,3)
 3. priority 50
    resubmit(,10)
    10. No match.
            drop
    resubmit(,4)
 4. reg0=0,dl_vlan=30, priority 99
    output:1
    strip_vlan
    output:3
     >> skipping output to input port
    output:4

Final flow: unchanged
Megaflow: recirc_id=0,eth,in_port=3,vlan_tci=0x0000,dl_src=00:00:00:00:00:00,dl_dst=ff:ff:ff:ff:ff:ff,dl_type=0x0000
Datapath actions: push_vlan(vid=30,pcp=0),1,pop_vlan,4
```

Then we see that it is output to p1 with an 802.1Q tag and then to p4 without one:

```
Datapath actions: push_vlan(vid=30,pcp=0),1,pop_vlan,4
```

Some more examples matching the rules in table 4

```
 cookie=0x0, duration=505.707s, table=4, n_packets=0, n_bytes=0, priority=99,reg0=0,dl_vlan=20 actions=output:p1,strip_vlan,output:p2
 cookie=0x0, duration=505.706s, table=4, n_packets=0, n_bytes=0, priority=99,reg0=0,dl_vlan=30 actions=output:p1,strip_vlan,output:p3,output:p4
```

VLAN 20 is action=strip_vlan and output to port 1(skipped as its input port), 2

```
ovs-appctl ofproto/trace br0 in_port=1,dl_dst=90:12:34:56:78:90,dl_vlan=20
Flow: in_port=1,dl_vlan=20,dl_vlan_pcp=0,vlan_tci1=0x0000,dl_src=00:00:00:00:00:00,dl_dst=90:12:34:56:78:90,dl_type=0x0000

bridge("br0")
-------------
 0. priority 0
    resubmit(,1)
 1. in_port=1, priority 99
    resubmit(,2)
 2. priority 32768
    learn(table=10,NXM_OF_VLAN_TCI[0..11],NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[],load:NXM_OF_IN_PORT[]->NXM_NX_REG0[0..15])
     >> suppressing side effects, so learn action ignored
    resubmit(,3)
 3. priority 50
    resubmit(,10)
    10. No match.
            drop
    resubmit(,4)
 4. reg0=0,dl_vlan=20, priority 99
    output:1
     >> skipping output to input port
    strip_vlan
    output:2

Final flow: in_port=1,vlan_tci=0x0000,dl_src=00:00:00:00:00:00,dl_dst=90:12:34:56:78:90,dl_type=0x0000
Megaflow: recirc_id=0,eth,in_port=1,dl_vlan=20,dl_vlan_pcp=0,dl_src=00:00:00:00:00:00,dl_dst=90:12:34:56:78:90,dl_type=0x0000
Datapath actions: pop_vlan,2
```

VLAN 30 is action=strip_vlan and output to port 1(skipped as its input port), 3, 4

```
ovs-appctl ofproto/trace br0 in_port=1,dl_dst=90:12:34:56:78:90,dl_vlan=30
Flow: in_port=1,dl_vlan=30,dl_vlan_pcp=0,vlan_tci1=0x0000,dl_src=00:00:00:00:00:00,dl_dst=90:12:34:56:78:90,dl_type=0x0000

bridge("br0")
-------------
 0. priority 0
    resubmit(,1)
 1. in_port=1, priority 99
    resubmit(,2)
 2. priority 32768
    learn(table=10,NXM_OF_VLAN_TCI[0..11],NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[],load:NXM_OF_IN_PORT[]->NXM_NX_REG0[0..15])
     >> suppressing side effects, so learn action ignored
    resubmit(,3)
 3. priority 50
    resubmit(,10)
    10. No match.
            drop
    resubmit(,4)
 4. reg0=0,dl_vlan=30, priority 99
    output:1
     >> skipping output to input port
    strip_vlan
    output:3
    output:4

Final flow: in_port=1,vlan_tci=0x0000,dl_src=00:00:00:00:00:00,dl_dst=90:12:34:56:78:90,dl_type=0x0000
Megaflow: recirc_id=0,eth,in_port=1,dl_vlan=30,dl_vlan_pcp=0,dl_src=00:00:00:00:00:00,dl_dst=90:12:34:56:78:90,dl_type=0x0000
Datapath actions: pop_vlan,3,4
```
