require './peer'

class Routing

  attr_reader :routing_table

  def initialize
    @routing_table = []
    @id = $id
  end

  # Add an entry to the routing table
  def updateRoutingTable(node_id, ip_address)
    #puts('LOOKY LOOK')
    #puts(node_id)
    #puts(@id)
    if @id != node_id
      #puts('HEEEEEEERE')
      if @routing_table.detect{|x| x[:node_id] == node_id}.nil?                  # If entry not already in routing table
        @routing_table.push({:node_id => node_id, :ip_address => ip_address})    # Add entry to routing table
      end
    end
    puts('ROUTING')
    puts(@routing_table)
  end

  def getRoutingTableToSend(ip)
    rt_temp = []
    #rt_temp = @routing_table
    @routing_table.each do |x|
      rt_temp.push(x)
    end
    rt_temp.push({:node_id => @id, :ip_address => ip})
    puts('TEMP')
    puts(rt_temp)
    return rt_temp
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
  def findCloserNode(target_id, joining_id)
    #puts('NODE')
    #puts(node_id)
    #puts('TARGET')
    #puts(target_id)
    distance = (@id - target_id).abs
    closest_ip = nil

    @routing_table.each do |x|
      if (x[:node_id] - target_id).abs < distance && x[:node_id] != joining_id
        distance = (x[:node_id] - target_id).abs
        #closest_id = x[:node_id]
        closest_ip = x[:ip_address]
      end
    end

    return closest_ip
  end
end