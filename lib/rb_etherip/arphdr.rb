module RbEtherIP
  # struct arphdr
  #   { 8Byte
  #     unsigned short int ar_hrd; 2Byte
  #     unsigned short int ar_pro;
  #     unsigned char ar_hln;
  #     unsigned char ar_pln;
  #     unsigned short int ar_op;
  #   };
  class Arphdr
    def initialize; end

    # @return [String]
    def to_pack
      ar_hrd = [ARPHRD_ETHER].pack("S>")
      ar_pro = [ETH_P_IP].pack("S>")
      ar_hln = [ETH_ALEN].pack("C")
      ar_pln = [4].pack("C")
      ar_op = [ARPOP_REQUEST].pack("S>")

      ar_hrd + ar_pro + ar_hln + ar_pln + ar_op
    end
  end
end
