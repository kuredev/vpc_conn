# struct sockaddr_ll { 20 Byte
#   unsigned short sll_family;
#   unsigned short sll_protocol;
#   int            sll_ifindex;
#   unsigned short sll_hatype;
#   unsigned char  sll_pkttype;
#   unsigned char  sll_halen;
#   unsigned char  sll_addr[8];
# };
module RbEtherIP
  class SockAddressLLArp
    include RbEtherIP::Util

    # @param [String] if_name "eth0"
    def initialize(if_name)
      @if_name = if_name
    end

    # Used for Socket#bind
    # @return [String]
    def to_pack_from
      sll_family = [Socket::AF_PACKET].pack("S")
      sll_protocol = [0x0806].pack("S>") # htons(ETH_P_ARP)
      sll_ifindex = [if_name_to_index(@if_name)].pack("i")
      sll_hatype = [ARPHRD_ETHER].pack("S")
      sll_pkttype = [PACKET_BROADCAST].pack("C")
      sll_halen = [ETH_ALEN].pack("C")
      sll_addr = if_name_to_mac_adress(@if_name) + [0].pack("C") * 2

      sll_family + sll_protocol + sll_ifindex + sll_hatype + \
        sll_pkttype + sll_halen + sll_addr
    end

    # Used for Socket#sendo
    # @return [String]
    def to_pack_to
      sll_family = [Socket::AF_PACKET].pack("S")
      sll_protocol = [0x0806].pack("S>") # htons(ETH_P_ARP), see linux/if_ether.h
      sll_ifindex = [if_name_to_index(@if_name)].pack("i")
      sll_hatype = [ARPHRD_ETHER].pack("S")
      sll_pkttype = [PACKET_BROADCAST].pack("C")
      sll_halen = [ETH_ALEN].pack("C")
      sll_addr = [255].pack("C") * 8

      sll_family + sll_protocol + sll_ifindex + sll_hatype + \
        sll_pkttype + sll_halen + sll_addr
    end

    private

    # @param [String] if_name "eth0"
    # @return [Integer] 2
    def if_name_to_index(if_name)
      Socket.getifaddrs.find do |ifaddr|
        ifaddr.name == if_name
      end&.ifindex
    end
  end
end
