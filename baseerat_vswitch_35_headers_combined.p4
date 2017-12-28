
// Global constants

#define DUMMY_ID 0xABC
#define IDS_WIDTH 32  // for 3 leafs per bitmap with 10 bit-width
#define NUM_HOSTS 48


// Header types

header_type ethernet_t {
    fields {
        dstAddr : 48;
        srcAddr : 48;
        etherType : 16;
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

header_type bitmap_hdr_combined_t {
    fields {
        data_0 : 848;  // (10 * (32 + 48)) + 48
        data_1 : 848;  // (10 * (32 + 48)) + 48
        data_2 : 848;  // (10 * (32 + 48)) + 48
        data_3 : 448;  // (5 * (32 + 48)) + 48
    }
}

// Parser functions

parser start {
    return parse_ethernet;
}

#define ETHERTYPE_IPV4 0x0800

header ethernet_t ethernet_;

parser parse_ethernet {
    extract(ethernet_);
    return select(latest.etherType) {
        ETHERTYPE_IPV4 : parse_ipv4;
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

#define VXLAN_VNI_BASEERAT 0xABCDEF

header vxlan_t vxlan_;

parser parse_vxlan {
    extract(vxlan_);
    return select(latest.vni) {
        VXLAN_VNI_BASEERAT : parse_bitmap_hdr_combined;
        default: ingress;
    }
}

header bitmap_hdr_combined_t bitmap_hdr_combined_;

parser parse_bitmap_hdr_combined {
    extract(bitmap_hdr_combined_);
    return ingress;
}

action dummy_action() {

}

table dummy_table {
    reads {
        ethernet_.etherType : exact;
    }
    actions {
        dummy_action;
    }
    size: 1;
}

control ingress {
    apply(dummy_table);
}

control egress {
}

