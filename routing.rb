require './peer'

class Routing

  attr_reader :routing_table

  def initialize
    @routing_table = []
    @id = $id
  end


  # Add an entry to the routing table
  def updateRoutingTable(node_id, ip_address)
    if @id != node_id                                                            # If the ID is not that of the node (don't add self to table)
      if @routing_table.detect{|x| x[:node_id] == node_id}.nil?                  # If entry not already in routing table
        @routing_table.push({:node_id => node_id, :ip_address => ip_address})    # Add entry to routing table
      end
    end
  end


  # Copy the routing table and add own details to send in ROUTING_INFO messages
  def getRoutingTableToSend(ip)
    rt_temp = []                                          # Temporary routing table for sending

    # Copy routing table
    @routing_table.each do |x|
      rt_temp.push(x)
    end

    rt_temp.push({:node_id => @id, :ip_address => ip})    # Add own details to copy
    return rt_temp
  end


  # Remove an entry from the routing table
  def deleteRoutingTableEntry(key)
    @routing_table.each do |x|          # For each entry in routing table
      if x[:node_id] == key             # Check if entry is to be deleted
        @routing_table.delete(x)        # Delete relevant entry
      end
    end
  end


  # Search routing table for node numerically closest to target
  def findCloserNode(target_id, joining_id)
    distance = (@id - target_id).abs                                             # Determine how close node is to target
    closest_ip = nil                                                             # The node itself is currently closest to target

    # Check if a node in routing table is closer than this node
    @routing_table.each do |x|
      if (x[:node_id] - target_id).abs < distance && x[:node_id] != joining_id   # If entry is closer than current closest
        distance = (x[:node_id] - target_id).abs                                 # Make this entry the new closest
        closest_ip = x[:ip_address]                                              # Get IP address of node closest to target
      end
    end

    return closest_ip                                                            # Return IP of closest node in routing table to target
  end
end