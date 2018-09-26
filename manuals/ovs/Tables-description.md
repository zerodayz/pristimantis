## Tables description

## Implementing Table 0: Admission control

Table 0 is where the packets are entering the switch. We use this stage to discard the packets that are for some reason invalid.

```
ovs-ofctl add-flow br0 \
    "table=0, dl_src=01:00:00:00:00:00/01:00:00:00:00:00, actions=drop"
    ovs-ofctl add-flow br0 \
        "table=0, dl_dst=01:80:c2:00:00:00/ff:ff:ff:ff:ff:f0, actions=drop"
ovs-ofctl add-flow br0 "table=0, priority=0, actions=resubmit(,1)"
```

And we can check for the flows created for this table

```
ovs-ofctl dump-flows br0 table=0
 cookie=0x0, duration=20.175s, table=0, n_packets=0, n_bytes=0, dl_src=01:00:00:00:00:00/01:00:00:00:00:00 actions=drop
 cookie=0x0, duration=14.976s, table=0, n_packets=0, n_bytes=0, dl_dst=01:80:c2:00:00:00/ff:ff:ff:ff:ff:f0 actions=drop
 cookie=0x0, duration=4.663s, table=0, n_packets=0, n_bytes=0, priority=0 actions=resubmit(,1)
 ```

 The flow with priority=0 is lower than the default, so that flows that don't match either of the "drop" flows the packet will go on to pipeline stage 1 in OpenFlow table 1.

## Implementing Table 1: VLAN Input Processing

Let's start by adding a low-priority flow that drops all packets, before we add flows that pass through acceptable packets. You can think of this as a "default drop" rule:

```
ovs-ofctl add-flow br0 "table=1, priority=0, actions=drop"
```

Then we create trunk port p1, OpenFlow port 1, it accepts any packet regardless of VLAN, so we can just re-submit everything on port 1 to next table.

```
ovs-ofctl add-flow br0 \
    "table=1, priority=99, in_port=1, actions=resubmit(,2)"
```

On the access ports, we want to accept any packet that has no VLAN header, tag it with the access port's VLAN number, and then pass it along to the next stage

```
ovs-ofctl add-flows br0 - <<'EOF'
  table=1, priority=99, in_port=2, vlan_tci=0, actions=mod_vlan_vid:20, resubmit(,2)
  table=1, priority=99, in_port=3, vlan_tci=0, actions=mod_vlan_vid:30, resubmit(,2)
  table=1, priority=99, in_port=4, vlan_tci=0, actions=mod_vlan_vid:30, resubmit(,2)
EOF
```
And we can check for the flows created for this table

```
ovs-ofctl dump-flows br0 table=1
 cookie=0x0, duration=69.550s, table=1, n_packets=0, n_bytes=0, priority=99,in_port=p1 actions=resubmit(,2)
 cookie=0x0, duration=16.058s, table=1, n_packets=0, n_bytes=0, priority=99,in_port=p2,vlan_tci=0x0000 actions=mod_vlan_vid:20,resubmit(,2)
 cookie=0x0, duration=16.057s, table=1, n_packets=0, n_bytes=0, priority=99,in_port=p3,vlan_tci=0x0000 actions=mod_vlan_vid:30,resubmit(,2)
 cookie=0x0, duration=16.057s, table=1, n_packets=0, n_bytes=0, priority=99,in_port=p4,vlan_tci=0x0000 actions=mod_vlan_vid:30,resubmit(,2)
 cookie=0x0, duration=186.181s, table=1, n_packets=0, n_bytes=0, priority=0 actions=drop
```

## Implementing Table 2: MAC+VLAN Learning for Ingress Port

This table allows the switch we're implementing to learn that the packet's source MAC is located on the packet's ingress port in the packet's VLAN.

```
ovs-ofctl add-flow br0 \
    "table=2 actions=learn(table=10, NXM_OF_VLAN_TCI[0..11], \
                           NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[], \
                           load:NXM_OF_IN_PORT[]->NXM_NX_REG0[0..15]), \
                     resubmit(,3)"
```

The "learn" action (an Open vSwitch extension to OpenFlow) modifies a flow table based on the content of the flow currently being processed. Here's how you can interpret each part of the "learn" action above

```
table=10

    Modify flow table 10.  This will be the MAC learning table.

NXM_OF_VLAN_TCI[0..11]

    Make the flow that we add to flow table 10 match the same VLAN
    ID that the packet we're currently processing contains.  This
    effectively scopes the MAC learning entry to a single VLAN,
    which is the ordinary behavior for a VLAN-aware switch.

NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[]

    Make the flow that we add to flow table 10 match, as Ethernet
    destination, the Ethernet source address of the packet we're
    currently processing.

load:NXM_OF_IN_PORT[]->NXM_NX_REG0[0..15]

    Whereas the preceding parts specify fields for the new flow to
    match, this specifies an action for the flow to take when it
    matches.  The action is for the flow to load the ingress port
    number of the current packet into register 0 (a special field
    that is an Open vSwitch extension to OpenFlow).
```

And we can check for the flows created for this table

```
ovs-ofctl dump-flows br0 table=2
 cookie=0x0, duration=1218.366s, table=2, n_packets=0, n_bytes=0, actions=learn(table=10,NXM_OF_VLAN_TCI[0..11],NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[],load:NXM_OF_IN_PORT[]->NXM_NX_REG0[0..15]),resubmit(,3)
```

## Implementing Table 3: Look Up Destination Port

This table figures out what port we should send the packet to based on the destination MAC and VLAN. That is, if we've learned the location of the destination (from table 2 processing some previous packet with that destination as its source), then we want to send the packet there.

```
ovs-ofctl add-flow br0 \
    "table=3 priority=50 actions=resubmit(,10), resubmit(,4)"
```

And we can check for the flows created for this table

```
ovs-ofctl dump-flows br0 table=3
 cookie=0x0, duration=61.023s, table=3, n_packets=0, n_bytes=0, priority=50 actions=resubmit(,10),resubmit(,4)
```

The flow's first action resubmits to table 10, the table that the "learn" action modifies. As you saw previously, the learned flows in this table write the learned port into register 0. If the destination for our packet hasn't been learned, then there will be no matching flow, and so the "resubmit" turns into a no-op. Because registers are initialized to 0, we can use a register 0 value of 0 in our next pipeline stage as a signal to flood the packet.  

The second action resubmits to table 4, continuing to the next pipeline stage.

## Implementing Table 4: Output Processing

At entry to stage 4, we know that register 0 contains either the desired output port or is zero if the packet should be flooded. We also know that the packet's VLAN is in its 802.1Q header, even if the VLAN was implicit because the packet came in on an access port.

The job of the final pipeline stage is to actually output packets. The job is trivial for output to our trunk port p1:

```
ovs-ofctl add-flow br0 "table=4 reg0=1 actions=1"
```

For output to the access ports, we just have to strip the VLAN header before outputting the packet:

```
ovs-ofctl add-flows br0 - <<'EOF'
table=4 reg0=2 actions=strip_vlan,2
table=4 reg0=3 actions=strip_vlan,3
table=4 reg0=4 actions=strip_vlan,4
EOF
```

And we can check for the flows created for this table

```
ovs-ofctl dump-flows br0 table=4
 cookie=0x0, duration=52.753s, table=4, n_packets=0, n_bytes=0, reg0=0x1 actions=output:p1
 cookie=0x0, duration=36.683s, table=4, n_packets=0, n_bytes=0, reg0=0x2 actions=strip_vlan,output:p2
 cookie=0x0, duration=36.683s, table=4, n_packets=0, n_bytes=0, reg0=0x3 actions=strip_vlan,output:p3
 cookie=0x0, duration=36.683s, table=4, n_packets=0, n_bytes=0, reg0=0x4 actions=strip_vlan,output:p4
```
