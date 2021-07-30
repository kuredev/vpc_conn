module RbEtherIP
  class RecvMessage
    def initialize(mesg)
      @mesg = mesg # 42Byte?
      # イーサネット: 14Byte
      # ARP：28Byte
    end

    # @return [String] ["", "", "", "", "", ""]
    def sender_mac_address
      @mesg[6, 6].bytes.map { |byte| byte.to_s(16) }
    end
  end
end
