module VpcConn
  # EtherHeader
  class EtherFrame

    # @param [String(Binary)] mesg
    def initialize(mesg)
      @mesg = mesg
    end

    def arp?
      @mesg.byteslice(12, 2).bytes.join == "86"
    end

    # @return [String] ["", "", "", "", "", ""]
    def sender_mac_address
      @mesg[6, 6].bytes.map { |byte| byte.to_s(16) }
    end

    def src_mac_addr_bin
      @mesg[6, 6]
    end

    def src_ip_addr_bin
      @mesg[26, 4]
    end

    def to_ip_header
      IPHeader.new(bin_data: @mesg.byteslice(14, 20))
    end

    def rewrite_ip_header(ip_header_bin)
      @mesg[14, 20] = ip_header_bin
    end

    def to_bin
      @mesg
    end

    def recalculate_ip_checksum!
      ip_header = to_ip_header
      ip_header.recalculate_checksum!
      rewrite_ip_header(ip_header.to_pack)
    end

    def rewrite_dst_mac_addr(bin_addr)
      @mesg[0, 6] = bin_addr
    end

    # in case of arp
    def rewrite_src_mac_addr_in_arp(bin_addr)
      @mesg[6, 6] = bin_addr
      @mesg[22, 6] = bin_addr
    end

    def rewrite_src_mac_addr(bin_addr)
      @mesg[6, 6] = bin_addr
    end

    def rewrite_src_ip_addr(ip_addr_bin)
      @mesg[26, 4] = ip_addr_bin
    end

    def rewrite_dst_ip_addr(ip_addr_bin)
      @mesg[30, 4] = ip_addr_bin
    end
  end
end
