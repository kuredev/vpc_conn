require "ipaddr"

module RbEtherIP
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

    # IPAddr
    def dst_addr
      IPAddr.new(@dst_addr)
    end
  end

end
