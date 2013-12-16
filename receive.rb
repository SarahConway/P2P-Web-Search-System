require 'json'
require './peer'

class Receive

  def initialize(socket, msg, port, rt, index)
    @socket = socket
    @msg = msg
    @id = $id
    @port = port
    @rt = rt
    @index = index
  end

  # Listen for incoming messages
  def listen

    puts('listening')
    while true
      received_data = p @socket.recv(1000)      # Receive
      respond(JSON.parse(received_data))
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
        #puts('ROUTING')
        #puts(@rt.routing_table)

        # Find suitable node and forward JOINING_NETWORK_RELAY
        if @rt.routing_table.length > 0
          closest_node_ip = @rt.findCloserNode(received['target_id'], received['node_id'])
          if closest_node_ip != nil
            puts('sending JOINING_NETWORK_RELAY to')
            puts(closest_node_ip)
            @socket.send @msg.JOINING_NETWORK_RELAY(received['node_id'], received['target_id'], @id), 0, '127.0.0.1', closest_node_ip
          end
        end

      when 'JOINING_NETWORK_RELAY'
        puts('JOINING_NETWORK_RELAY')
        # If not target, forward JOINING_NETWORK_RELAY
        if received['node_id'] != @id
          closest_node_ip = @rt.findCloserNode(received['target_id'], received['node_id'])
          if !closest_node_ip.nil?
            puts('sending JOINING_NETWORK_RELAY to')
            puts(closest_node_ip)
            @socket.send @msg.JOINING_NETWORK_RELAY(received['node_id'], received['target_id'], received['gateway_id']), 0, '127.0.0.1', closest_node_ip
          end
        end

        # Send ROUTING_INFO to gateway node
        closest_node_ip = @rt.findCloserNode(received['gateway_id'], received['node_id'])
        puts('CLOSEST')
        puts(closest_node_ip)
        if !closest_node_ip.nil?
          puts('sending ROUTING_INFO to')
          puts(closest_node_ip)
          @socket.send @msg.ROUTING_INFO(received['gateway_id'], received['gateway_id'], @port, @rt.getRoutingTableToSend(@port)), 0, '127.0.0.1', closest_node_ip
        end

      when 'ROUTING_INFO'
        puts('ROUTING_INFO')
        #puts(received)

        # Check if its for this node
        if received['node_id'] == @id       # If message is intended for this node
          # Store received routing info
          received['route_table'].each do |x|
            @rt.updateRoutingTable(x['node_id'], x['ip_address'])
          end
        else
          closest_node_ip = @rt.findCloserNode(@id, received['node_id'])
          if !closest_node_ip.nil?
            @socket.send @msg.ROUTING_INFO(received['gateway_id'], received['node_id'], @port, received['route_table']), 0, '127.0.0.1', closest_node_ip
          end
        end

      when 'LEAVING_NETWORK'
        puts('LEAVING_NETWORK')
        @rt.deleteRoutingTableEntry(received['node_id'])

      when 'INDEX'
        puts('INDEX')

        if received['target_id'] == @id     # If message is intended for this node
          # Store new index
          @index.addIndex(received['keyword'], received['link'])
        else
          closest_node_ip = @rt.findCloserNode(@id, received['target_id'])
          if !closest_node_ip.nil?
            @socket.send msg.INDEX(received['target_id'], @id, received['keyword'], received['link']), 0, '127.0.0.1', closest_node_ip
          end
        end

        # Respond with ACK
        #@socket.send @msg.ACK()

      when 'SEARCH'
        puts('SEARCH')

        #puts(received['word'][0].to_s)
        puts(@index.getKeywordIndexes(received['word'][0].to_s))
        if received['node_id'] == @id     # If message is intended for this node
          closest_node_ip = @rt.findCloserNode(@id, received['sender_id'])
          if !closest_node_ip.nil?
            @socket.send @msg.SEARCH_RESPONSE(received['word'], received['sender_id'], @id, @index.getKeywordIndexes(received['word'].to_s)), 0, '127.0.0.1', closest_node_ip
          end
        else
          closest_node_ip = @rt.findCloserNode(@id, received['node_id'])
          if !closest_node_ip.nil?
            @socket.send @msg.SEARCH(received['word'], received['node_id'], received['sender_id']), 0, '127.0.0.1', closest_node_ip    # Could just send on received
          end
        end

      when 'SEARCH_RESPONSE'
        puts('SEARCH_RESPONSE')

      when 'PING'
        puts('PING')
        # Respond with ACK
        # Send PING to next node if not final target

      when 'ACK'
        puts('ACK')
    end
  end
end