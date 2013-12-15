require 'json'

class Messages

  def JOINING_NETWORK(node_id, ip_address)
    message = {:type => 'JOINING_NETWORK', :node_id => node_id, :ip_address => ip_address}
    return message.to_json
  end

  def JOINING_NETWORK_RELAY(node_id, gateway_id)
    message = {:type => 'JOINING_NETWORK_RELAY', :node_id => node_id, :gateway_id => gateway_id}
    return message.to_json
  end

  def ROUTING_INFO(gateway_id, node_id, ip_address, route_table)
    message = {:type => 'ROUTING_INFO', :gateway_id => gateway_id, :node_id => node_id, :ip_address => ip_address, :route_table => route_table}
    return message.to_json
  end

  def LEAVING_NETWORK(node_id)
    message = {:type => 'LEAVING_NETWORK', :node_id => node_id}
    return message.to_json
  end

  def INDEX(target_id, sender_id, keyword, link)
    message = {:type => 'INDEX', :target_id => target_id, :sender_id => sender_id, :keyword => keyword, :link => link}
    return message.to_json
  end

  def SEARCH(word, node_id, sender_id)
    message = {:type => 'SEARCH', :word => word, :node_id => node_id, :sender_id => sender_id}
    return message.to_json
  end

  def SEARCH_RESPONSE(word, node_id, sender_id, response)
    message = {:type => 'SEARCH_RESPONSE', :word => word, :node_id => node_id, :sender_id => sender_id, :response => response}
    return message.to_json
  end

  def PING(target_id, sender_id, ip_address)
    message = {:type => 'PING', :target_id => target_id, :sender_id => sender_id, :ip_address => ip_address}
    return message.to_json
  end

  def ACK(node_id, ip_address)
    message = {:type => 'ACK', :node_id => node_id, :ip_address => ip_address}
    return message.to_json
  end
end

#uigbiujhuh