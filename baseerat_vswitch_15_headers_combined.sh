#! /bin/sh -ve

# Please make sure that you update the path to the current OVS directory.
DIR=~/ovs/utilities

$DIR/ovs-ofctl --protocols=OpenFlow15 del-flows br0

# Add baseerat headers
$DIR/ovs-ofctl --protocols=OpenFlow15 add-flow br0 "table=0,priority=32768,ipv4__dstAddr=0xC0A8380B \
                           actions=add_header:bitmap_hdr_combined_, \
                                   set_field:0x112233441F2F3F4F5F6F223344551F2F3F4F5F6F334455661F2F3F4F5F6F445566771F2F3F4F5F6F556677881F2F3F4F5F6F667788991F2F3F4F5F6F778899001F2F3F4F5F6F889900111F2F3F4F5F6F990011221F2F3F4F5F6F001122331F2F3F4F5F6F1F2F3F4F5F6F->bitmap_hdr_combined__data_0, \
                                   set_field:0x112233441F2F3F4F5F6F223344551F2F3F4F5F6F334455661F2F3F4F5F6F445566771F2F3F4F5F6F556677881F2F3F4F5F6F1F2F3F4F5F6F->bitmap_hdr_combined__data_1, \
                                   deparse, \
                                   output:3"

$DIR/ovs-ofctl --protocols=OpenFlow15 add-flow br0 "table=0,priority=32768,ipv4__dstAddr=0xC0A8380C \
                           actions=add_header:bitmap_hdr_combined_, \
                                   set_field:0x112233441F2F3F4F5F6F223344551F2F3F4F5F6F334455661F2F3F4F5F6F445566771F2F3F4F5F6F556677881F2F3F4F5F6F667788991F2F3F4F5F6F778899001F2F3F4F5F6F889900111F2F3F4F5F6F990011221F2F3F4F5F6F001122331F2F3F4F5F6F1F2F3F4F5F6F->bitmap_hdr_combined__data_0, \
                                   set_field:0x112233441F2F3F4F5F6F223344551F2F3F4F5F6F334455661F2F3F4F5F6F445566771F2F3F4F5F6F556677881F2F3F4F5F6F1F2F3F4F5F6F->bitmap_hdr_combined__data_1, \
                                   deparse, \
                                   output:4"
