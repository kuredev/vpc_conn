require "ipaddr"

module VpcConn
  class IPHeader
    def initialize(version: nil, header_length: nil, tos: nil, total_length: nil,
                   id: nil, flags: nil, fragment: nil, time_to_live: nil, protocol: nil,
                   checksum: nil, src_addr: nil, dst_addr: nil, bin_data: nil)

      if bin_data.nil?
        @version = version
        @header_length = header_length
        @tos = tos
        @total_length = total_length
        @id = id
        @flags = flags
        @fragment = fragment
        @time_to_live = time_to_live
        @protocol = protocol
        @checksum = checksum
        @src_addr = src_addr
        @dst_addr = dst_addr
      else
        @dst_addr = bin_data.byteslice(16, 4).bytes.map(&:to_s).join(".")
        @bin_data = bin_data

        ip = bin_data.unpack("B*")[0]
        @version = ip[0, 4].to_i(2)
        @header_length = ip[4, 4].to_i(2)
        @tos = ip[8, 8].to_i(2)
        @total_length = ip[16, 16].to_i(2)
        @id = ip[32, 16].to_i(2)
        @flags = ip[48, 3].to_i(2)
        @fragment = ip[51, 13].to_i(2)
        @time_to_live = ip[64, 8].to_i(2)
        @protocol = ip[72, 8].to_i(2)
        @checksum = ip[80, 16].to_i(2)
        @src_addr = [ip[96, 32]].pack("B*").bytes.map { |c| c.to_s }.join(".")
        @dst_addr = [ip[128, 32]].pack("B*").bytes.map { |c| c.to_s }.join(".")
      end
    end

    def to_pack
      bynary_data =
        @version.to_s(2).rjust(4, "0") +
        @header_length.to_s(2).rjust(4, "0") +
        @tos.to_s(2).rjust(8, "0") +
        @total_length.to_s(2).rjust(16, "0") +
        @id.to_s(2).rjust(16, "0") +
        @flags.to_s(2).rjust(3, "0") +
        @fragment.to_s(2).rjust(13, "0") +
        @time_to_live.to_s(2).rjust(8, "0") +
        @protocol.to_s(2).rjust(8, "0") +
        @checksum.to_s(2).rjust(16, "0") +
        IPAddr.new(@src_addr).to_i.to_s(2).rjust(32, "0") +
        IPAddr.new(@dst_addr).to_i.to_s(2).rjust(32, "0")

      data_byte_arr = bynary_data.scan(/.{1,8}/)
      data_byte_arr.map! { |byte| byte.to_i(2).chr } # TO ASCII
      data_byte_arr.join
    end

    def carry_up(num)
      carry_up_num = num.length - 16
      original_value = num[carry_up_num, 16]
      carry_up_value = num[0, carry_up_num]
      sum = original_value.to_i(2) + carry_up_value&.to_i(2)
      result = sum ^ 0xffff
      result
    end

    def recalculate_checksum!
      d16bit_version_headerl_tos_str = @version.to_s(2).rjust(4, "0") +
                                      @header_length.to_s(2).rjust(4, "0") +
                                      @tos.to_s(2).rjust(8, "0")
      d16bit_total_length = @total_length
      d16bit_id = @id # Integer
      d16bit_flag_fragment_str = @flags.to_s(2).rjust(3, "0") +
                            @fragment.to_s(2).rjust(13, "0")
      d16bit_ttl_protocol = @time_to_live.to_s(2).rjust(8, "0") +
                           @protocol.to_s(2).rjust(8, "0")
      d16bit_checksum = 0
      d16bit_src_addr_s1 = ::IPAddr.new(@src_addr).to_i.to_s(2).rjust(32, "0").byteslice(0, 16)
      d16bit_src_addr_s2 = ::IPAddr.new(@src_addr).to_i.to_s(2).rjust(32, "0").byteslice(16, 16)
      d16bit_dst_addr_s1 = ::IPAddr.new(@dst_addr).to_i.to_s(2).rjust(32, "0").byteslice(0, 16)
      d16bit_dst_addr_s2 = ::IPAddr.new(@dst_addr).to_i.to_s(2).rjust(32, "0").byteslice(16, 16)

      sum_16bit = d16bit_version_headerl_tos_str.to_i(2) +
                  d16bit_total_length +
                  d16bit_id +
                  d16bit_flag_fragment_str.to_i(2) +
                  d16bit_ttl_protocol.to_i(2) +
                  d16bit_src_addr_s1.to_i(2) +
                  d16bit_src_addr_s2.to_i(2) +
                  d16bit_dst_addr_s1.to_i(2) +
                  d16bit_dst_addr_s2.to_i(2)

      @checksum = carry_up(sum_16bit.to_s(2).rjust(16, "0"))
    end

    # IPAddr
    def dst_addr
      IPAddr.new(@dst_addr)
    end
  end

end
