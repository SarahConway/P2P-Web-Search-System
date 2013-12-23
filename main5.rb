require 'json'
require 'socket'
require 'optparse'
require 'pp'
require 'thread'
require './peer'

options = {}
option_parser = OptionParser.new do |opts|
  opts.banner = 'Usage: main.rb [options]'

  opts.on('--boot', '--node_id [node_id]', 'Node ID') do |a|
    options[:node_id] = a
  end

  opts.on('--bootstrap', '--bootstrap_ip [bootstrap_ip]', 'Bootstrap IP') do |b|
    options[:bootstrap_ip] = b
  end

  opts.on('--id', '--node_id [node_id]', 'Node ID') do |c|
    options[:node_id] = c
  end

  opts.on('--port', '--port [port]', 'Port to listen on') do |d|
    options[:port] = d
  end
end
option_parser.parse!

socket = UDPSocket.new                       # Create new socket
socket.bind('127.0.0.1', options[:port])     # Bind socket to port

p1 = Peer.new()
p1.init(socket, options[:port])
p1.joinNetwork(options[:bootstrap_ip], options[:node_id], 'd')

$t1.join
