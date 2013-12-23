require 'json'
require './peer'

class Receive
  attr_accessor :ack_index_received
  attr_accessor :ack_received

  def initialize(socket, msg, port, rt, index)
    @socket = socket
    @msg = msg
    @id = $id
    @port = port
    @rt = rt
    @index = index

    @ack_index_received = false
    @ack_received = false
  end

  # Listen for incoming messages
  def listen

    puts('listening')
    while true
      begin
        received_data = p @socket.recv(1000)        # Receive
        Thread.new do                               # Start a new thread to handle the incoming message
          respond(JSON.parse(received_data))        # Determine how to respond to received and parsed message
        end
      rescue Errno::ECONNRESET                      # If there was an issue in replaying in respond function - e.g. remote host no longer up
        puts('Connection to remote host failed')
      end
    end
  end


  # Response to received messages
  def respond(received)
    case received['type']

      when 'JOINING_NETWORK'
        puts('JOINING_NETWORK')

        # Reply with ROUTING_INFO
        @socket.send @msg.ROUTING_INFO(@id, received['node_id'], @port , @rt.getRoutingTableToSend(@port)), 0, '127.0.0.1', received['ip_address']

        # Put joining node in routing table
        @rt.updateRoutingTable(received['node_id'], received['ip_address'])

        # If there is a node closer to target in routing table forward JOINING_NETWORK_RELAY
        if @rt.routing_table.length > 0
          closest_node_ip = @rt.findCloserNode(received['target_id'], received['node_id'])
          if closest_node_ip != nil
            @socket.send @msg.JOINING_NETWORK_RELAY(received['node_id'], received['target_id'], @id), 0, '127.0.0.1', closest_node_ip
          end
        end

      when 'JOINING_NETWORK_RELAY'
        puts('JOINING_NETWORK_RELAY')

        # If not target, forward JOINING_NETWORK_RELAY to closer node
        if received['node_id'] != @id
          closest_node_ip = @rt.findCloserNode(received['target_id'], received['node_id'])
          if !closest_node_ip.nil?
            @socket.send @msg.JOINING_NETWORK_RELAY(received['node_id'], received['target_id'], received['gateway_id']), 0, '127.0.0.1', closest_node_ip
          end
        end

        # Send ROUTING_INFO to gateway node
        closest_node_ip = @rt.findCloserNode(received['gateway_id'], nil)
        if !closest_node_ip.nil?
          @socket.send @msg.ROUTING_INFO(received['gateway_id'], received['node_id'], @port, @rt.getRoutingTableToSend(@port)), 0, '127.0.0.1', closest_node_ip
        end

      when 'ROUTING_INFO'
        puts('ROUTING_INFO')

        # Store received routing info
        received['route_table'].each do |x|
          @rt.updateRoutingTable(x['node_id'], x['ip_address'])
        end

        # If this is the gateway node forward ROUTING_INFO to joining node
        if received['gateway_id'] == @id
          joining_ip = @rt.routing_table.detect{|x| x[:node_id] == received['node_id']}[:ip_address]
          @socket.send @msg.ROUTING_INFO(@id, received['node_id'], @port, received['route_table']), 0, '127.0.0.1', joining_ip
        end

        # If message not intended for this node send it closer to target
        if received['node_id'] != @id
          closest_node_ip = @rt.findCloserNode(received['gateway_id'], nil)
          if !closest_node_ip.nil?
            @socket.send @msg.ROUTING_INFO(received['gateway_id'], received['node_id'], @port, received['route_table']), 0, '127.0.0.1', closest_node_ip
          end
        end

      when 'LEAVING_NETWORK'
        puts('LEAVING_NETWORK')
        @rt.deleteRoutingTableEntry(received['node_id'])      # Delete leaving node from routing table

      when 'INDEX'
        puts('INDEX')

        # If message is intended for this node
        if received['target_id'] == @id

          # Store new index
          @index.addIndex(received['keyword'], received['link'])

          # Respond with ACK_INDEX
          closest_node_ip = @rt.findCloserNode(received['sender_id'], nil)
          if !closest_node_ip.nil?
            @socket.send @msg.ACK_INDEX(received['sender_id'], received['keyword']), 0, '127.0.0.1', closest_node_ip
          end

        # If message not for this node, send closer to target
        else
          closest_node_ip = @rt.findCloserNode(received['target_id'], nil)
          if !closest_node_ip.nil?
            @socket.send @msg.INDEX(received['target_id'], received['sender_id'], received['keyword'], received['link']), 0, '127.0.0.1', closest_node_ip
          end
        end

      when 'SEARCH'
        puts('SEARCH')

        # If message is intended for this node ger results and send SEARCH_RESPONSE
        if received['node_id'] == @id
          closest_node_ip = @rt.findCloserNode(received['sender_id'], nil)
          if !closest_node_ip.nil?
            @socket.send @msg.SEARCH_RESPONSE(received['word'], received['sender_id'], @id, @index.getKeywordIndexes(received['word'].to_s)), 0, '127.0.0.1', closest_node_ip
          end

        # If message not for this node, send closer to target
        else
          closest_node_ip = @rt.findCloserNode(received['node_id'], nil)
          if !closest_node_ip.nil?
            @socket.send @msg.SEARCH(received['word'], received['node_id'], received['sender_id']), 0, '127.0.0.1', closest_node_ip
          end
        end

      when 'SEARCH_RESPONSE'
        puts('SEARCH_RESPONSE')

        # If message is intended for this node
        if received['node_id'] == @id

          received['response'].each do |x|
            result = SearchResult.new(received['word'], x['url'], x['rank'])
            ap result
          end

        # If message is not intended for this node, send closer to target
        else
          closest_node_ip = @rt.findCloserNode(received['node_id'], nil)
          if !closest_node_ip.nil?
            @socket.send @msg.SEARCH_RESPONSE(received['word'], received['node_id'], received['sender_id'], received['response']), 0, '127.0.0.1', closest_node_ip
          end
        end

      when 'PING'
        puts('PING')

        # Respond with ACK
        @socket.send @msg.ACK(received['target_id'], @port), 0, '127.0.0.1', received['ip_address']

        # Send PING to next node if not final target
        if received['target_id'] != @id

          # Send closer to target
          closest_node_ip = @rt.findCloserNode(received['target_id'], nil)
          if !closest_node_ip.nil?
            @socket.send @msg.PING(received['target_id'], received['sender_id'], @port), 0, '127.0.0.1', closest_node_ip
            @pinged_ip = closest_node_ip

            # Wait up to 10s for ACK
            time = Time.now
            while Time.now - time < 10 && !@ack_received
            end

            # If no ACK received delete node from routing table
            if !@ack_received
              @rt.deleteRoutingTableEntry(@rt.routing_table.detect{|x| x[:ip_address == closest_node_ip]}[:node_id])   # Delete from routing table
            else
              @ack_received = false       # If ACK received reset value to false
            end
          end
        end

      when 'ACK'
        puts('ACK')

        if received['ip_address'] == @pinged_ip     # If ACK is from expected node
          @ack_received = true                      # Indicate that ACK has been received
        end

      when 'ACK_INDEX'
        puts('ACK_INDEX')

        # If message is intended for this node
        if received['node_id'] == @id
          @ack_index_received = true            # Indicate that ACK_INDEX has been received

        # If message not intended for this node, send closer to target
        else
          closest_node_ip = @rt.findCloserNode(received['node_id'], nil)
          if !closest_node_ip.nil?
            @socket.send @msg.ACK_INDEX(received['node_id'], received['keyword']), 0, '127.0.0.1', closest_node_ip
          end
        end

    end
  end
end