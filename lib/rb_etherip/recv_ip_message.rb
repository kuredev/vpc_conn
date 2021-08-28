module RbEtherIP
  # IPHeader + EtherHeader + Payload(Caplused Data)
  class IPPacket

    # @param [String(Binary)]
    def initialize(mesg)
      @mesg = mesg
    end

    def to_excluded_etherip
      @mesg.byteslice(22, @mesg.bytesize - 22)
    end
  end
end
