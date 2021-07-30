require "socket"

module RbEtherIP
  class EtherHeader
    ETH_TYPE_NUMBER_ARP = 0x0800

    def initialize(if_name)
      @if_name = if_name
    end

    def to_pack
      #ether_dhost = [255].pack("C") * 6
      ether_dhost = "\xDC\xA62\x91\xA9\xF5".b
      ether_shost = if_name_to_mac_adress(@if_name)
      ether_type = [ETH_TYPE_NUMBER_ARP].pack("S>")

      ether_dhost + ether_shost + ether_type
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
  end
end
