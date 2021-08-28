module RbEtherIP
  module Util
    private

    # @param [String] if_name "eth0"
    # @return [String(Binary)]
    def if_name_to_mac_adress(if_name)
      sockaddr = Socket.getifaddrs
                       .select { |a| a.name == if_name.to_s }
                       .map(&:addr)
                       .find { |a| a.pfamily == Socket::PF_PACKET }
                       .to_sockaddr
      sockaddr[-6..-1]
    end

    # return String(Binary)
    def if_name_to_ip_addr(if_name)
      ip_addr_str = Socket.getifaddrs.select{|x| x.name == if_name and x.addr.ipv4?}.first.addr.ip_address.split(".")
      ip_addr_str.map(&:to_i).pack("C*")
    end
  end
end
