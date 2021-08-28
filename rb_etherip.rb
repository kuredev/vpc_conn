require "optparse"
require "./lib/rb_etherip"

# Usage
# ruby rb_etherip.rb -o eth1 -t eth0 -d 20.0.0.2 -s 20.0.0.1

required = [:outside_interface, :tunnel_interface, :dst_addr, :src_addr]
options = {}
opt = OptionParser.new do |opt|
  opt.on("-o VALUE", "--outside_interface VALUE", "") { |v| options[:outside_interface] = v }
  opt.on("-t VALUE", "--tunnel_interface VALUE", "") { |v| options[:tunnel_interface] = v }
  opt.on("-d VALUE", "--dst_addr VALUE", "") { |v| options[:dst_addr] = v }
  opt.on("-s VALUE", "--src_addr VALUE", "") { |v| options[:src_addr] = v }
  opt.on("-r VALUE", "--remote_ip_addrs VALUE", "") { |v| options[:remote_ip_addrs] = v }

  opt.parse!(ARGV)

  for field in required
    raise ArgumentError.new("必須オプション（#{field}）が不足しています。") if options[field].nil?
  end
end

# pp options[:remote_ip_addrs]
# exit

tunnel = RbEtherIP::Tunnel.new(
  outside_interface: options[:outside_interface],
  tunnel_interface: options[:tunnel_interface],
  dst_addr: options[:dst_addr],
  src_addr: options[:src_addr],
  remote_ip_addrs: options[:remote_ip_addrs],
)
tunnel.run
