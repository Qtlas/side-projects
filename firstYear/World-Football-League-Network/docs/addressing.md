# Addressing plan

The whole design uses the supernet 172.20.0.0/16. The backbone takes
172.20.128.0/24 and the WAN link takes 172.20.255.0/28. Each club owns a single
172.20.x.0/24 block, where x runs from 129 to 133, and every VLAN subnet,
point-to-point link and management address of a club fits inside that /24. On
the edge router, the NAT ACL groups the club source ranges together with
/22-style wildcards.

Because all clubs share the same internal layout, you obtain any concrete
address by dropping the club x into the offset tables further down.

## Backbone (172.20.128.0/24, VLAN 60 Backbone-Mgmt) and WAN

| Device | Interface | Address | Role |
|---|---|---|---|
| R-EDGE | Fa0/0 (WAN) | 172.20.255.3/28 | NAT outside, default route |
| R-EDGE | Fa0/1 (VLAN 60) | 172.20.128.1/24 | OSPF area 0, priority 100, NAT inside |
| R-MCY | Fa0/0 | 172.20.128.2/24 | club uplink |
| R-BVB | Fa0/0 | 172.20.128.3/24 | club uplink |
| R-FCB | Fa0/0 | 172.20.128.4/24 | club uplink |
| R-JUV | Fa0/0 | 172.20.128.5/24 | club uplink |
| SRV-BACKBONE | VLAN 60 | 172.20.128.6/24 | DNS (`ns1.wfl.lan`) and NTP |
| R-AJX | Fa0/0 | 172.20.128.7/24 | club uplink |
| SW-BACKBONE | VLAN 60 SVI | 172.20.128.8/24 | management over SSH |

## Clubs

| Club | Code | x | Network | Domain | OSPF area | Core router-id |
|---|---|---|---|---|---|---|
| Manchester City | MCY | 129 | 172.20.129.0/24 | mcy.wfl.lan | 1 | 20.20.20.20 |
| Borussia Dortmund | BVB | 130 | 172.20.130.0/24 | bvb.wfl.lan | 5 | 30.30.30.30 |
| FC Barcelona | FCB | 131 | 172.20.131.0/24 | fcb.wfl.lan | 2 | 40.40.40.40 |
| Juventus | JUV | 132 | 172.20.132.0/24 | juv.wfl.lan | 3 | 50.50.50.50 |
| Ajax Amsterdam | AJX | 133 | 172.20.133.0/24 | ajx.wfl.lan | 4 | 60.60.60.60 |

The backbone edge router R-EDGE uses router-id 1.1.1.1 and is the router that
originates the default route into OSPF area 0.

## Per-club /24 layout (drop in the club x)

| VLAN | Name | Subnet | Gateway (core SVI) | DHCP pool | Static hosts |
|---|---|---|---|---|---|
| 10 | Players | 172.20.x.0/26 | 172.20.x.1 | 172.20.x.2 to .62 | none |
| 20 | Technical-Staff | 172.20.x.64/28 | 172.20.x.65 | 172.20.x.66 to .78 | none |
| 30 | Admin-Staff | 172.20.x.96/27 | 172.20.x.97 | 172.20.x.98 to .126 | none |
| 40 | Network-Mgmt | 172.20.x.128/29 | 172.20.x.129 | static | switch management SVIs |
| 50 | Servers | 172.20.x.136/29 | 172.20.x.137 | static | club server .138 |
| 666 | BlackHole | unused ports | none | none | disabled access ports |

The club router reaches its core over a /30 point-to-point link,
172.20.x.144/30, with the router on .145 and the core on .146.

Fixed last octets inside each club /24:

| Host | Address |
|---|---|
| Core switch SVI VLAN 40 (gateway) | 172.20.x.129 |
| Distribution switch 1 SVI VLAN 40 | 172.20.x.130 |
| Distribution switch 2 SVI VLAN 40 | 172.20.x.131 |
| Access switch SVI VLAN 40 | 172.20.x.132 |
| Club server (DNS, DHCP, web, SFTP) | 172.20.x.138 |
| Core uplink to the club router | 172.20.x.146 |
| Club router uplink to the core | 172.20.x.145 |

On every club switch, the management ACL `ACL-SSH-MGMT` allows SSH only from the
VLAN 40 management segment (172.20.x.128/29). On SW-BACKBONE it allows SSH from
172.20.128.0/24.

## DNS

The backbone server SRV-BACKBONE (172.20.128.6) is authoritative for `wfl.lan`
and for the reverse zone `128.20.172.in-addr.arpa`. For each club it forwards
the `<club>.wfl.lan` zone and the `<x>.20.172.in-addr.arpa` reverse zone to the
club server on 172.20.x.138, and it sends everything else out to 8.8.8.8 and
1.1.1.1.

Each club server is authoritative for its own `<club>.wfl.lan` forward zone and
its `<x>.20.172.in-addr.arpa` reverse zone. It accepts dynamic updates from its
local Kea DDNS on 127.0.0.1, and forwards any other query back to the backbone.

## DHCP

Kea DHCP4 on each club server leases addresses to VLANs 10, 20 and 30 through
the relay set on the core switch (`ip helper-address 172.20.x.138`). VLAN 40 and
VLAN 50 stay static. The leases carry the club gateway, the club DNS server on
172.20.x.138, the club domain and the backbone NTP server on 172.20.128.6.
Leased hosts are then registered automatically in the club zones through dynamic
DNS.
