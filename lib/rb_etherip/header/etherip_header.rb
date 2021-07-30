module RbEtherIP
  class EtherIPHeader
    def initialize
      @version = 3 # 4bit, 必ず3
      @reserved = 0 # 12bit, 必ず0
    end

    def to_pack
      bynary_data =
        @version.to_s(2).rjust(4, "0") +
        @reserved.to_s(2).rjust(12, "0")

      data_byte_arr = bynary_data.scan(/.{1,8}/)
      data_byte_arr.map! { |byte| byte.to_i(2).chr } # TO ASCII
      data_byte_arr.join
    end
  end
end
