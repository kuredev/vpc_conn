require_relative "vpc_conn/header/ether_header"
require_relative "vpc_conn/header/etherip_header"
require_relative "vpc_conn/header/icmp_header"
require_relative "vpc_conn/header/ip_header"
require_relative "vpc_conn/sock_address_ll"
require_relative "vpc_conn/util"
require_relative "vpc_conn/tunnel"
require_relative "vpc_conn/arphdr"
require_relative "vpc_conn/arp_client"
require_relative "vpc_conn/ether_arp"
require_relative "vpc_conn/ether_header"
require_relative "vpc_conn/recv_message"
require_relative "vpc_conn/recv_ip_message"
require_relative "vpc_conn/sock_address_ll_arp"
require_relative "vpc_conn/arp_entry"
require_relative "vpc_conn/arp_table"

module VpcConn
end

SOL_PACKET            = 0x0107 # bits/socket.h
IFINDEX_SIZE          = 0x0004 # sizeof(ifreq.ifr_ifindex) on 64bit
IFREQ_SIZE            = 0x0028 # sizeof(ifreq) on 64bit
SIOCGIFINDEX          = 0x8933 # bits/ioctls.h
PACKET_MR_PROMISC     = 0x0001 # netpacket/packet.h
PACKET_MREQ_SIZE      = 0x0010 # sizeof(packet_mreq) on 64bit
PACKET_ADD_MEMBERSHIP = 0x0001 # netpacket/packet.h
ETH_P_ALL = [ 0x0003 ].pack('S>').unpack('S').first # linux/if_ether.h, needs to be native-endian uint16_t
