# struct ether_header
# { 14Byte
#   u_int8_t  ether_dhost[ETH_ALEN]; 6Byte
#   u_int8_t  ether_shost[ETH_ALEN]; 6Byte
#   u_int16_t ether_type; 2Byte
# }
module RbEtherIP
  class EtherHeader
    include RbEtherIP::Util

    def initialize(if_name)
      @if_name = if_name
    end

    def to_pack
      ether_dhost = [255].pack("C") * 6
      ether_shost = if_name_to_mac_adress(@if_name)
      # ether_type = [ETH_TYPE_NUMBER_ARP].pack("S>")
      ether_type = [0x0806].pack("S>")

      ether_dhost + ether_shost + ether_type
    end
  end
end
