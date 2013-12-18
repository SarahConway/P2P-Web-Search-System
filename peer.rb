require './hashing'
require './receive'
require './messages'
require './routing'
require './indexing'

class Peer

  # Initialise the node
  def init(socket, port)
    @socket = socket
    @msg = Messages.new
    @hash = Hashing.new
    @index = Indexing.new
    @port = port
  end

  # Join the network
  def joinNetwork(bootstrap_ip, id, target_id)
    $id = @hash.hashCode(id)                                    # Hash word to get numerical ID of node
    puts($id)
    @target_id = @hash.hashCode(target_id)                      # Get ID of node to send JOINING_NETWORK_RELAY to
    @rt = Routing.new                                           # Instance of Routing class (manages routing table)
    @receive = Receive.new(@socket, @msg, @port, @rt, @index)   # Instance of Receive class (manages received messages)

    if !bootstrap_ip.nil?                                       # If not bootstrap node
      puts('Sending JOINING_NETWORK to gateway')
      @socket.send @msg.JOINING_NETWORK($id, @target_id, @port), 0, '127.0.0.1', bootstrap_ip   # Send JOINING_NETWORK to gateway node
    end
    $t1 = Thread.new do       # Create new thread
      @receive.listen         # Listen for incoming messages
    end
    return 0                  # Return network ID
  end

  # Leave the network
  def leaveNetwork(network_id)
    puts('LEAVING')
    puts(@rt.routing_table)
    @rt.routing_table.each do |x|             # For each node in the routing table
      puts('sending leaving message to ')
      puts(x[:ip_address])
      @socket.send @msg.LEAVING_NETWORK($id), 0, '127.0.0.1', x[:ip_address]    # Send a LEAVING_NETWORK message
    end
    #@socket.close           # Close socket/leave network
    $t1.exit                 # Leave the network
  end

  # Index a page and send indexes to appropriate nodes
  def indexPage(url, unique_words)
    #puts(@rt.routing_table)
    unique_words.each do |x|                                        # For each unique word
      closest_node_ip = @rt.findCloserNode(@hash.hashCode(x), nil)  # Find closest routing table entry to target
      #puts('sending INDEX message to')
      #puts(closest_node_ip)
      if !closest_node_ip.nil?
        @socket.send @msg.INDEX(@hash.hashCode(x), $id, x, url), 0, '127.0.0.1', closest_node_ip  # Send INDEX to relevant node
      end
    end
  end

  # Search for a set of words in the network
  def search(words)
    words.each do |x|                                                 # For each word
      closest_node_ip = @rt.findCloserNode(@hash.hashCode(x), nil)    # Find closest routing table entry to the target
      if !closest_node_ip.nil?
        @socket.send @msg.SEARCH(x, @hash.hashCode(x), $id), 0, '127.0.0.1', closest_node_ip    # Send SEARCH to relevant node
      end
    end
  end
end