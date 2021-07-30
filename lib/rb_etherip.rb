require_relative "rb_etherip/header/ether_header"
require_relative "rb_etherip/header/etherip_header"
require_relative "rb_etherip/header/icmp_header"
require_relative "rb_etherip/header/ip_header"
require_relative "rb_etherip/sock_address_ll"
require_relative "rb_etherip/util"
require_relative "rb_etherip/tunnel"
require_relative "rb_etherip/arphdr"
require_relative "rb_etherip/arp_client"
require_relative "rb_etherip/ether_arp"
require_relative "rb_etherip/ether_header"
require_relative "rb_etherip/recv_message"
require_relative "rb_etherip/sock_address_ll_arp"
require_relative "rb_etherip/arp_entry"
require_relative "rb_etherip/arp_table"

module RbEtherIP
end

SOL_PACKET            = 0x0107 # bits/socket.h
IFINDEX_SIZE          = 0x0004 # sizeof(ifreq.ifr_ifindex) on 64bit
IFREQ_SIZE            = 0x0028 # sizeof(ifreq) on 64bit
SIOCGIFINDEX          = 0x8933 # bits/ioctls.h
PACKET_MR_PROMISC     = 0x0001 # netpacket/packet.h
PACKET_MREQ_SIZE      = 0x0010 # sizeof(packet_mreq) on 64bit
PACKET_ADD_MEMBERSHIP = 0x0001 # netpacket/packet.h
ETH_P_ALL = [ 0x0003 ].pack('S>').unpack('S').first # linux/if_ether.h, needs to be native-endian uint16_t
