#! /bin/sh -ve

# Please make sure that you update the path to the current OVS directory.
DIR=~/ovs/utilities

$DIR/ovs-ofctl --protocols=OpenFlow15 del-flows br0

# Add baseerat headers
$DIR/ovs-ofctl --protocols=OpenFlow15 add-flow br0 "table=0,priority=32768,ipv4__dstAddr=0xC0A8380B \
                           actions=add_header:bitmap_hdr0_, \
                                   set_field:0x11223344->bitmap_hdr0__ids, \
                                   set_field:0x1F2F3F4F5F6F->bitmap_hdr0__bitmap, \
                                   add_header:bitmap_hdr1_, \
                                   set_field:0x22334455->bitmap_hdr1__ids, \
                                   set_field:0x1F2F3F4F5F6F->bitmap_hdr1__bitmap, \
                                   add_header:bitmap_hdr2_, \
                                   set_field:0x33445566->bitmap_hdr2__ids, \
                                   set_field:0x1F2F3F4F5F6F->bitmap_hdr2__bitmap, \
                                   add_header:bitmap_hdr3_, \
                                   set_field:0x44556677->bitmap_hdr3__ids, \
                                   set_field:0x1F2F3F4F5F6F->bitmap_hdr3__bitmap, \
                                   add_header:default_bitmap_, \
                                   set_field:0x1F2F3F4F5F6F->default_bitmap__bitmap, \
                                   deparse, \
                                   output:3"

$DIR/ovs-ofctl --protocols=OpenFlow15 add-flow br0 "table=0,priority=32768,ipv4__dstAddr=0xC0A8380C \
                           actions=add_header:bitmap_hdr0_, \
                                   set_field:0x11223344->bitmap_hdr0__ids, \
                                   set_field:0x1F2F3F4F5F6F->bitmap_hdr0__bitmap, \
                                   add_header:bitmap_hdr1_, \
                                   set_field:0x22334455->bitmap_hdr1__ids, \
                                   set_field:0x1F2F3F4F5F6F->bitmap_hdr1__bitmap, \
                                   add_header:bitmap_hdr2_, \
                                   set_field:0x33445566->bitmap_hdr2__ids, \
                                   set_field:0x1F2F3F4F5F6F->bitmap_hdr2__bitmap, \
                                   add_header:bitmap_hdr3_, \
                                   set_field:0x44556677->bitmap_hdr3__ids, \
                                   set_field:0x1F2F3F4F5F6F->bitmap_hdr3__bitmap, \
                                   add_header:default_bitmap_, \
                                   set_field:0x1F2F3F4F5F6F->default_bitmap__bitmap, \
                                   deparse, \
                                   output:4"
