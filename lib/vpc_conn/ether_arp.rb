# /usr/include/netinet/if_ether.h
# struct  ether_arp { 28Byte
#   struct  arphdr ea_hdr; 8Byte
#   uint8_t arp_sha[ETH_ALEN]; 6Byte
#   uint8_t arp_spa[4]; 4Byte
#   uint8_t arp_tha[ETH_ALEN]; 6Byte
#   uint8_t arp_tpa[4]; 4Byte
# };
module VpcConn
  class EtherArp
    # @param [String] dst_ip_addr "192.,168.1.1"
    def initialize(src_if_name, dst_ip_addr)
      @src_if_name = src_if_name
      @dst_ip_addr = dst_ip_addr
    end

    def to_pack
      ea_hdr = VpcConn::Arphdr.new.to_pack
      arp_sha = if_name_to_mac_adress(@src_if_name)
      arp_spa = if_name_to_ip_address(@src_if_name).split(".").map do |n|
        [n.to_i].pack("C")
      end.join

      arp_tha = [0].pack("C") * ETH_ALEN
      arp_tpa = @dst_ip_addr.split(".").map(&:to_i).pack("C*")

      ea_hdr + arp_sha + arp_spa + arp_tha + arp_tpa
    end

    private

    # @param [String] if_name "eth0"
    # @return [String] "\n\x16S\xD0\xFC\x80"
    def if_name_to_mac_adress(if_name)
      sockaddr = Socket.getifaddrs
                       .select { |a| a.name == if_name.to_s }
                       .map(&:addr)
                       .find { |a| a.pfamily == Socket::PF_PACKET }
                       .to_sockaddr
      sockaddr[-6..-1]
    end

    # @param [String] if_name "eth0"
    # @return [String] "192.168.106.129"
    def if_name_to_ip_address(if_name)
      Socket.getifaddrs.select do |x|
        x.name == if_name and x.addr.ipv4?
      end.first.addr.ip_address
    end
  end
end
