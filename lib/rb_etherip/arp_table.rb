module RbEtherIP
  class ArpTable
    def initialize
      @arp_entries = []
    end

    def add_arp_entry(arp_entry)
      @arp_entries << arp_entry
    end

    def self.search_arp_entry(ip_addr)
      # toDO
      nil
    end
  end
end
