VpcConn is a tool that enables communication between two VPC hosts with overlapping addresses.

This tool is experimental.

--

Image of what VpcConn can do.

![vpc_conn_en](https://user-images.githubusercontent.com/33872553/131209579-2b26f738-5b03-4a1f-ba87-40292f3a264a.png)

Outline of the mechanism.

![vpc_conn_en2](https://user-images.githubusercontent.com/33872553/131215290-1ac0927f-e63f-4aa5-bd17-8fe53df80b8b.png)

--

This tool currently has the following restrictions.

- Can only make a call from one side
- No encryption between tunnels
- Can only be processed by a single thread

--

HowToUse

- Prepare two VPCs with the same CIDR
- Prepare a total of 4 EC2 instances.
  - Place two EC2 instances in one VPC
    - One is used as a router for tunnels and one is used as a host for sending and receiving.
  - Set up three ENIs for your EC2 instance for your router.
    - For management
    - For tunnel
    - For communication with the host in the VPC
  - Set the same IP address as the IP address of the receiving host as the secondary IP of the ENI of the router of the VPC of the sending host.

```ruby
$ git clone git@github.com:kuredev/vpc_conn.git
  # Commands on the router of the VPC of the host for sending
$ sudo ruby rb_etherip.rb -o eth1 -t eth2 -d [Peer Router IP Address] -s [IP address to communicate with peer VPC host] -r [Same IP address as the receiving host]
  # Commands on the router of the VPC of the host for receiving
$ sudo ruby rb_etherip.rb -o eth1 -t eth2 -d [Peer Router IP Address] -s [IP address to communicate with peer VPC host]
```
