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
  def joinNetwork(bootstrap_ip, identifier, target_identifier)
    $id = @hash.hashCode(identifier)                                    # Hash word to get numerical ID of node
    puts($id)
    @target_id = @hash.hashCode(target_identifier)                      # Get ID of node to send JOINING_NETWORK_RELAY to
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
      puts('sending INDEX message to')
      puts(closest_node_ip)
      if !closest_node_ip.nil?
        @socket.send @msg.INDEX(@hash.hashCode(x), $id, x, url), 0, '127.0.0.1', closest_node_ip  # Send INDEX to relevant node

        # Wait up to 30s for ACK_INDEX
        time = Time.now
        while Time.now - time < 10 && !@receive.ack_index_received  #30
        end

        # If no ACK_INDEX received send PING
        if !@receive.ack_index_received
          @socket.send @msg.PING(@hash.hashCode(x), $id, @port), 0, '127.0.0.1', closest_node_ip
          puts('sending PING to')
          puts(closest_node_ip)

          # Wait up to 10s for ACK
          time = Time.now
          while Time.now - time < 10 && !@receive.ack_received
          end

          # If no ACK received delete node from routing table
          if !@receive.ack_received
            puts('deleting')
            puts(@rt.routing_table)
            @rt.deleteRoutingTableEntry(@hash.hashCode(x))
            puts('deleted')
            puts(@rt.routing_table)
          else
            @receive.ack_received = false
          end

        else
          puts('ACK INDEX RECEIVED')
          @receive.ack_index_received = false
        end
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

class SearchResult

  attr_accessor :words
  attr_accessor :url
  attr_accessor :frequency

  def initialize(words, url, frequency)
    @words = words
    @url = url
    @frequency = frequency
  end

end