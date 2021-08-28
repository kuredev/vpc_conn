require "socket"
require_relative "./header/etherip_header"

module VpcConn
  class Tunnel
    include Util
    # constructor
    #
    # @param outside_interface [String]
    # @param tunnel_interface [String]
    def initialize(outside_interface: , tunnel_interface: , dst_addr:, src_addr:, remote_ip_addrs: nil)
      @outside_interface = outside_interface
      @tunnel_interface = tunnel_interface
      @peer_addr = dst_addr
      @src_addr = src_addr
      @remote_ip_addrs = remote_ip_addrs
    end

    # Run as a bridge until Ctrl + C.
    def run
      outside_sock = Socket.new(
                       Socket::AF_PACKET,
                       Socket::SOCK_RAW,
                       ETH_P_ALL
                      )
      tunnel_sock = Socket.open(
                    Socket::AF_INET,
                    Socket::SOCK_RAW,
                    97 # EtherIP
                  )

      bind_if(outside_sock, @outside_interface)
      promiscuous(outside_sock, @outside_interface)
      tunnel_sock.bind(Socket.sockaddr_in(nil, @src_addr))

      outside_sock_object_id = outside_sock.object_id
      tunnel_sock_object_id = tunnel_sock.object_id
      @src_mac_cache = "" # String(binary)
      @src_ip_addr_cache = "" # String(binary)
      while true
        ret = IO::select([outside_sock, tunnel_sock])
        ret[0].each do |sock|
          payload = sock.recv(65535)
          if sock.object_id === outside_sock_object_id
            puts "from outside"
            recv_ether_frame = EtherFrame.new(payload)
            if @remote_ip_addrs.nil?
              if recv_ether_frame.arp?
                recv_ether_frame.rewrite_src_mac_addr(@src_mac_cache)
              else
                recv_ether_frame.rewrite_dst_mac_addr(@src_mac_cache)
                recv_ether_frame.rewrite_dst_ip_addr(@src_ip_addr_cache)
              end
            else
              dst_ip_addr = recv_ether_frame.to_ip_header.dst_addr
              dst_mac_addr = resolve_arp_via_tunnel(tunnel_sock, dst_ip_addr.to_s)
              recv_ether_frame.rewrite_dst_mac_addr(dst_mac_addr)
            end
            tunnel_sock.send(EtherIPHeader.new.to_pack + recv_ether_frame.to_bin, 0, Socket.sockaddr_in(nil, @peer_addr))
          else
            puts "from tunnel"
            recv_ether_frame = EtherFrame.new(IPPacket.new(payload).to_excluded_etherip)
            if @remote_ip_addrs.nil?
              if recv_ether_frame.arp?
                if_src_mac_addr = if_name_to_mac_adress(@outside_interface)
                @src_mac_cache = recv_ether_frame.src_mac_addr_bin
                recv_ether_frame.rewrite_src_mac_addr_in_arp(if_src_mac_addr)
              else
                @src_mac_cache = recv_ether_frame.src_mac_addr_bin
                @src_ip_addr_cache = recv_ether_frame.src_ip_addr_bin

                if_src_mac_addr = if_name_to_mac_adress(@outside_interface)
                recv_ether_frame.rewrite_src_mac_addr(if_src_mac_addr)

                ip_addr_bin = if_name_to_ip_addr(@outside_interface)
                recv_ether_frame.rewrite_src_ip_addr(ip_addr_bin)
                recv_ether_frame.recalculate_ip_checksum!
              end
            else
              if_src_mac_addr = if_name_to_mac_adress(@outside_interface)
              recv_ether_frame.rewrite_src_mac_addr(if_src_mac_addr)

              recv_ether_frame.recalculate_ip_checksum!
            end
            outside_sock.send(recv_ether_frame.to_bin, 0)
          end
        end
      end
    end

    private

    # @return [Array<String(Binary)>]
    def resolve_arp_via_tunnel(tunnel_sock, dst_ip_addr)
      arp_client = VpcConn::ArpClient.new(src_if_name: "eth2", dst_ip_addr: dst_ip_addr.to_s)
      arp_data = arp_client.data_to_send
      tunnel_sock.bind(Socket.sockaddr_in(nil, @src_addr))
      tunnel_sock.send(EtherIPHeader.new.to_pack + arp_data, 0, Socket.sockaddr_in(nil, @peer_addr))
      mesg, _ = tunnel_sock.recvfrom(1500)
      mesg[44, 6]
    end

    def bind_if(socket, interface)
      ifreq = [ interface, '' ].pack('a16a16')

      socket.ioctl(SIOCGIFINDEX, ifreq)
      index_str = ifreq[16, 4]

      eth_p_all_hbo = [ ETH_P_ALL ].pack('S').unpack('S>').first
      sll = [ Socket::AF_PACKET, eth_p_all_hbo, index_str ].pack('SS>a16') # sockaddr_ll
      socket.bind(sll)
    end

    def promiscuous(socket, interface)
      ifreq = [interface].pack('a' + IFREQ_SIZE.to_s)
      socket.ioctl(SIOCGIFINDEX, ifreq)

      if_num = ifreq[Socket::IFNAMSIZ, IFINDEX_SIZE]
      mreq = if_num.dup
      mreq << [PACKET_MR_PROMISC].pack('s')
      mreq << ("\x00" * (PACKET_MREQ_SIZE - mreq.length))
      socket.setsockopt(SOL_PACKET, PACKET_ADD_MEMBERSHIP, mreq)
    end
  end
end
