#! /bin/sh -ve

# Please make sure that you update the path to the current OVS directory.
DIR=~/ovs/utilities

$DIR/ovs-ofctl --protocols=OpenFlow15 del-flows br0

# Add baseerat headers
$DIR/ovs-ofctl --protocols=OpenFlow15 add-flow br0 "table=0,priority=32768,ipv4__dstAddr=0xC0A8380B \
                           actions=add_header:bitmap_hdr_combined_, \
                                   set_field:0x112233441F2F3F4F5F6F223344551F2F3F4F5F6F334455661F2F3F4F5F6F445566771F2F3F4F5F6F556677881F2F3F4F5F6F1F2F3F4F5F6F->bitmap_hdr_combined__data, \
                                   deparse, \
                                   output:3"

$DIR/ovs-ofctl --protocols=OpenFlow15 add-flow br0 "table=0,priority=32768,ipv4__dstAddr=0xC0A8380C \
                           actions=add_header:bitmap_hdr_combined_, \
                                   set_field:0x112233441F2F3F4F5F6F223344551F2F3F4F5F6F334455661F2F3F4F5F6F445566771F2F3F4F5F6F556677881F2F3F4F5F6F1F2F3F4F5F6F->bitmap_hdr_combined__data, \
                                   deparse, \
                                   output:4"
