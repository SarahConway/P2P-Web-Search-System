require './hashing'
require './receive'
require './messages'
require './routing'
require './indexing'

class Peer


  def init(socket, port)
    @socket = socket
    @msg = Messages.new
    @hash = Hashing.new
    @index = Indexing.new
    @port = port
  end

  # Join the network
  def joinNetwork(bootstrap_ip, id, target_id)
    $id = @hash.hashCode(id)
    puts($id)
    @target_id = @hash.hashCode(target_id)
    @rt = Routing.new
    @receive = Receive.new(@socket, @msg, @port, @rt, @index)

    if !bootstrap_ip.nil?                   # If not first node
      puts('Sending JOINING_NETWORK to gateway')
      @socket.send @msg.JOINING_NETWORK($id, @target_id, @port), 0, '127.0.0.1', bootstrap_ip
    end
    $t1 = Thread.new do       # Create new thread
      @receive.listen         # Listen for incoming messages
    end
    return 0      # Return network ID
  end

  # Leave the network
  def leaveNetwork(network_id)
    puts('LEAVING')
    puts(@rt.routing_table)
    @rt.routing_table.each do |x|           # For each node in the routing table
      puts('sending leaving message to ')
      puts(x[:ip_address])
      @socket.send @msg.LEAVING_NETWORK($id), 0, '127.0.0.1', x[:ip_address]    # Send a LEAVING_NETWORK message
    end
    #@socket.close           # Close socket/leave network
    $t1.exit
  end

  # Index a page and send indexes to appropriate nodes
  def indexPage(url, unique_words)
    unique_words.each do |x|                                   # For each unique word
      closest_node_ip = @rt.findCloserNode($id, @hash.hashCode(x))
      if !closest_node_ip.nil?
        @socket.send @msg.INDEX(@hash.hashCode(x), $id, x, url), 0, '127.0.0.1', closest_node_ip  # Send URL to relevant node
      end
    end
  end

  # Search for a set of word in the network
  def search(words)
    words.each do |x|
      closest_node_ip = @rt.findCloserNode($id, @hash.hashCode(x))
      if !closest_node_ip.nil?
        @socket.send @msg.SEARCH(x, @hash.hashCode(x), $id), 0, '127.0.0.1', closest_node_ip
      end
    end
  end
end