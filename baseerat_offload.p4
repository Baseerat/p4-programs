
header_type ethernet_t {
    fields {
        dstAddr : 48;
        srcAddr : 48;
        etherType : 16;
    }
}

header_type sr_t {
    fields {
        portMap : 8;
        srType: 8;
    }
}

header_type ipv4_t {
    fields {
        version : 4;
        ihl : 4;
        diffserv : 8;
        totalLen : 16;
        identification : 16;
        flags : 3;
        fragOffset : 13;
        ttl : 8;
        protocol : 8;
        hdrChecksum : 16;
        srcAddr : 32;
        dstAddr: 32;
    }
}

header_type udp_t {
    fields {
        srcPort : 16;
        dstPort : 16;
        length_ : 16;
        checksum : 16;
    }
}

header_type vxlan_t {
    fields {
        flags : 8;
        reserved : 24;
        vni : 24;
        reserved2 : 8;
    }
}

parser start {
    return parse_ethernet;
}

#define ETHERTYPE_SR 0xFFFF
#define ETHERTYPE_IPV4 0x0800

header ethernet_t ethernet_;

parser parse_ethernet {
    extract(ethernet_);
    return select(latest.etherType) {
        ETHERTYPE_SR : parse_sr;
        ETHERTYPE_IPV4 : parse_ipv4;
        default: ingress;
    }
}

#define SRTYPE_SR 0xFF
#define SRTYPE_IPV4 0x08

header sr_t sr_;

parser parse_sr {
    extract(sr_);
    return select(latest.srType) {
        SRTYPE_IPV4 : parse_ipv4;
        default: ingress;
    }
}

#define IP_PROTOCOLS_UDP 17

header ipv4_t ipv4_;

field_list ipv4_checksum_list {
        ipv4_.version;
        ipv4_.ihl;
        ipv4_.diffserv;
        ipv4_.totalLen;
        ipv4_.identification;
        ipv4_.flags;
        ipv4_.fragOffset;
        ipv4_.ttl;
        ipv4_.protocol;
        ipv4_.srcAddr;
        ipv4_.dstAddr;
}

field_list_calculation ipv4_checksum {
    input {
        ipv4_checksum_list;
    }
    algorithm : csum16;
    output_width : 16;
}

calculated_field ipv4_.hdrChecksum  {
    verify ipv4_checksum;
    update ipv4_checksum;
}

parser parse_ipv4 {
    extract(ipv4_);
    return select(latest.protocol) {
        IP_PROTOCOLS_UDP  : parse_udp;
        default: ingress;
    }
}

#define UDP_PORT_VXLAN 4789

header udp_t udp_;

field_list udp_checksum_list {
        ipv4_.srcAddr;
        ipv4_.dstAddr;
        8'0;
        ipv4_.protocol;
        udp_.length_;
        udp_.srcPort;
        udp_.dstPort;
        udp_.length_;
        payload;
}

field_list_calculation udp_checksum {
    input {
        udp_checksum_list;
    }
    algorithm : csum16;
    output_width : 16;
}

calculated_field udp_.checksum {
    update udp_checksum;
}

parser parse_udp {
    extract(udp_);
    return select(latest.dstPort) {
        UDP_PORT_VXLAN  : parse_vxlan;
        default: ingress;
    }
}

header vxlan_t vxlan_;

parser parse_vxlan {
    extract(vxlan_);
    return parse_inner_ethernet;
}

header ethernet_t inner_ethernet_;

parser parse_inner_ethernet {
    extract(inner_ethernet_);
    return select(latest.etherType) {
        ETHERTYPE_IPV4 : parse_inner_ipv4;
        default: ingress;
    }
}

header ipv4_t inner_ipv4_;

field_list inner_ipv4_checksum_list {
        inner_ipv4_.version;
        inner_ipv4_.ihl;
        inner_ipv4_.diffserv;
        inner_ipv4_.totalLen;
        inner_ipv4_.identification;
        inner_ipv4_.flags;
        inner_ipv4_.fragOffset;
        inner_ipv4_.ttl;
        inner_ipv4_.protocol;
        inner_ipv4_.srcAddr;
        inner_ipv4_.dstAddr;
}

field_list_calculation inner_ipv4_checksum {
    input {
        inner_ipv4_checksum_list;
    }
    algorithm : csum16;
    output_width : 16;
}

calculated_field inner_ipv4_.hdrChecksum  {
    verify inner_ipv4_checksum;
    update inner_ipv4_checksum;
}

parser parse_inner_ipv4 {
    extract(inner_ipv4_);
    return select(latest.protocol) {
        IP_PROTOCOLS_UDP  : parse_inner_udp;
        default: ingress;
    }
}

header udp_t inner_udp_;

field_list inner_udp_checksum_list {
        inner_ipv4_.srcAddr;
        inner_ipv4_.dstAddr;
        8'0;
        inner_ipv4_.protocol;
        inner_udp_.length_;
        inner_udp_.srcPort;
        inner_udp_.dstPort;
        inner_udp_.length_;
        payload;
}

field_list_calculation inner_udp_checksum {
    input {
        inner_udp_checksum_list;
    }
    algorithm : csum16;
    output_width : 16;
}

calculated_field inner_udp_.checksum {
    update inner_udp_checksum;
}

parser parse_inner_udp {
    extract(inner_udp_);
    return ingress;
}

// @Shahbaz: update this part with match action code

action action0() {
}

table table0 {
    reads {
        ethernet_.etherType : exact;
    }
    actions {
        action0;
    }
    size: 1;
}

control ingress {
    apply(table0);
}

control egress {
}
