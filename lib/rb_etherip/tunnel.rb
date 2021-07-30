require "socket"
require_relative "./header/etherip_header"

module RbEtherIP
  class Tunnel
    # constructor
    #
    # @param outside_interface [String]
    # @param tunnel_interface [String]
    def initialize(outside_interface: , tunnel_interface: , dst_addr:, src_addr:)
      @outside_interface = outside_interface
      @tunnel_interface = tunnel_interface
      @peer_addr = dst_addr
      @src_addr = src_addr
    end

    # 以下のヘッダの宛先MACアドレスを置き換える
    # @param [String] payload Ether + IP + ICMP
    # @return [String]
    def replace_dst_mac_addr(payload, dst_mac_addr)
      # d = payload.slice(0, 6).bytes.map { |byte| byte.to_s(16) }
      # s = payload.slice(6, 6).bytes.map { |byte| byte.to_s(16) }
      # pp d
      # pp s
      # pp dst_mac_addr
      payload[0, 6] = dst_mac_addr.join
      payload
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
      # bind_if(tunnel_sock, @tunnel_interface)

      promiscuous(outside_sock, @outside_interface)
      # promiscuous(tunnel_sock, @tunnel_interface)

      outside_sock_object_id = outside_sock.object_id
      tunnel_sock_object_id = tunnel_sock.object_id
      while true
        ret = IO::select([outside_sock, tunnel_sock])
        puts "受信"
        ret[0].each do |sock|
          payload = sock.recv(65535)
          if sock.object_id === outside_sock_object_id
            # Etherヘッダを付ける
            puts "外から受信"
            pp payload # Payload は Etherヘッダから付いてくる
            pp payload.size # 42, IP:20Byte, ICMP: 8Byte, Etherヘッダ 14Byte
            ip_header = IPHeader.new(bin_data: payload.byteslice(14, 20))
            dst_addr = ip_header.dst_addr # ★IPAddr
            arp_entry = RbEtherIP::ArpTable.search_arp_entry(dst_addr)
            if arp_entry.nil?
              # EtherIP越しにARPする
              # payload: ARP + Etherヘッダ
              arp_client = RbEtherIP::ArpClient.new(src_if_name: "eth2", dst_ip_addr: dst_addr.to_s)
              arp_data = arp_client.data_to_send
              tunnel_sock.bind(Socket.sockaddr_in(nil, @src_addr))
              tunnel_sock.send( EtherIPHeader.new.to_pack + arp_data, 0, Socket.sockaddr_in(nil, @peer_addr)) # 送るまでは出来る
              mesg, _ = tunnel_sock.recvfrom(1500) # 第3引数がある→ARPしか受信しない？、ない→全部受信する？
              dst_mac_addr = RbEtherIP::RecvMessage.new(mesg).sender_mac_address

              pp dst_mac_addr
              exit
            end

            payload = replace_dst_mac_addr(payload, dst_mac_addr)

            data = EtherIPHeader.new.to_pack
            tunnel_sock.bind(Socket.sockaddr_in(nil, @src_addr))
            tunnel_sock.send(data + payload, 0, Socket.sockaddr_in(nil, @peer_addr))
            exit
          else
            # Etherヘッダ(36Byte)を外す
            puts "トンネルから受信"
            pp payload.bytesize # => 82Byte -> IPヘッダより上を受信してる。Ehterヘッダは含まれていない。
            payload_excluded_etherip = payload.byteslice(22, payload.bytesize - 22)
            outside_sock.send(payload_excluded_etherip, 0)
          end
        end
      end
    end

    private

    # RAWソケット用のbind
    #  というよりは AF_PACKET(L2)のbindかな。
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
