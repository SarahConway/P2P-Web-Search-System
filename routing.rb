class Routing

  attr_reader :routing_table

  def initialize(id)
    @routing_table = []
    @id = id
  end

  # Add an entry to the routing table
  def updateRoutingTable(node_id, ip_address)
    if @id != node_id
      if @routing_table.detect{|x| x[:node_id] == node_id}.nil?                  # If entry not already in routing table
        @routing_table.push({:node_id => node_id, :ip_address => ip_address})    # Add entry to routing table
      end
    end
  end

  # Remove an entry from the routing table
  def deleteRoutingTableEntry(key)
    #puts('BEFORE')
    #puts(@routing_table)
    @routing_table.each do |x|          # For each entry in routing table
      if x[:node_id] == key             # Check if entry is to be deleted
        @routing_table.delete(x)        # Delete relevant entry
      end
    end
    #puts('END')
    #puts(@routing_table)
  end

  # Search routing table for node numerically closest to target
  def findCloserNode(node_id, target_id)
    distance = (node_id - target_id).abs
    closest_ip = nil

    @routing_table.each do |x|
      if (x[:node_id] - target_id).abs < distance && x[:node_id] != target_id
        distance = (x[:node_id] - target_id).abs
        #closest_id = x[:node_id]
        closest_ip = x[:ip_address]
      end
    end

    return closest_ip
  end
end