## Traces Examples

## DHCP Example

```
[root@compute-0 ~]# grep tap563172d5-5b /var/run/libvirt/qemu/* -B2
/var/run/libvirt/qemu/instance-00000006.xml-        <mac address='fa:16:3e:52:b7:60'/>
/var/run/libvirt/qemu/instance-00000006.xml-        <source bridge='qbr563172d5-5b'/>
/var/run/libvirt/qemu/instance-00000006.xml:        <target dev='tap563172d5-5b'/>

[root@compute-0 ~]# ovs-ofctl dump-ports-desc br-int | grep 563172d5-5b
 5(qvo563172d5-5b): addr:1a:3b:8f:97:b1:45

[root@compute-0 ~]# ovs-appctl ofproto/trace br-int in_port=5,udp,dl_src=fa:16:3e:52:b7:60,dl_dst=ff:ff:ff:ff:ff:ff,nw_dst=255.255.255.255,udp_dst=67,udp_src=68
Flow: udp,in_port=5,vlan_tci=0x0000,dl_src=fa:16:3e:52:b7:60,dl_dst=ff:ff:ff:ff:ff:ff,nw_src=0.0.0.0,nw_dst=255.255.255.255,nw_tos=0,nw_ecn=0,nw_ttl=0,tp_src=68,tp_dst=67

bridge("br-int")
----------------
 0. in_port=5, priority 9, cookie 0xbc726af4e1832313
    goto_table:25
25. in_port=5,dl_src=fa:16:3e:52:b7:60, priority 2, cookie 0xbc726af4e1832313
    NORMAL
     -> no learned MAC for destination, flooding

    bridge("br-ex")
    ---------------
         0. in_port=1, priority 2, cookie 0x8ab85aab2d9f188c
            drop

    bridge("br-isolated")
    ---------------------
         0. in_port=5, priority 2, cookie 0xba3b134c36f59548
            drop

bridge("br-tun")
----------------
 0. in_port=1, priority 1, cookie 0xb0127f1c32308d76
    goto_table:2
 2. dl_dst=01:00:00:00:00:00/01:00:00:00:00:00, priority 0, cookie 0xb0127f1c32308d76
    goto_table:22
22. dl_vlan=1, priority 1, cookie 0xb0127f1c32308d76
    pop_vlan
    set_field:0x2b->tun_id
    output:2
     -> output to kernel tunnel
    output:4
     -> output to kernel tunnel
    output:3
     -> output to kernel tunnel

Final flow: unchanged
Megaflow: recirc_id=0,eth,ip,in_port=5,vlan_tci=0x0000,dl_src=fa:16:3e:52:b7:60,dl_dst=ff:ff:ff:ff:ff:ff,nw_ecn=0,nw_frag=no
Datapath actions: push_vlan(vid=1,pcp=0),7,set(tunnel(tun_id=0x2b,src=172.17.2.15,dst=172.17.2.22,ttl=64,tp_dst=4789,flags(df|key))),pop_vlan,9,set(tunnel(tun_id=0x2b,src=172.17.2.15,dst=172.17.2.10,ttl=64,tp_dst=4789,flags(df|key))),9,set(tunnel(tun_id=0x2b,src=172.17.2.15,dst=172.17.2.11,ttl=64,tp_dst=4789,flags(df|key))),9
```
