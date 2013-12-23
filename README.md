P2P-Web-Search-System
=====================

Name: Sarah Conway
Student Number: 09408223

The spec was slightly altered to allow testing on a local machine.  In a proper system messages would be sent to a
remote machine using an IP address.  As all testing was completed on a local machine each node instead used a different
port and messages were sent to this.  This means that, for local testing, the routing table stores {node_id, port}
pairs though the hash table values are labelled the correct names of {node_id, ip_address}.  In addition, where
IP variables are used, e.g. closest_node_ip, these actually contain a port for the purposes of testing.  The port
number is passed to the node as an additional command line parameter and this became an additional parameter of the init
function.  For testing, therefore each node uses the same IP address and communicates with other nodes on different
ports.  In practice, for nodes on different machines to communicate with one another this would be switched, i.e. each
node would use the same port and would communicate with other nodes using different IP addresses.

Command Line Arguments
======================
To create the bootstrap node the following is used:

$--boot computer --port 8767

The --boot parameter gives the ID of the bootstrap node while the --port parameter is the port on which it listens.
The parameter values given here are examples and may be changed.

To create another node the following is used:

$--bootstrap 8767 --id cloud --port 8000

The bootstrap parameter is the port (would be IP address outside of testing) of a node that is already part of the
network. The parameter values given here are examples and may be changed.

Testing Files
=============

main.rb, main2.rb, main3.rb, main4.rb. main5.rb
These files were used for testing.  They parse the command line arguments and instantiate nodes as appropriate.  A
single file could equally have been used but this method allowed for easier testing as each node output to its own
terminal window.

Classes
=======

1. peer.rb
   This class implements the library that is defined as the spec, i.e. the init, joinNetwork, leaveNetwork, indexPage
   and search functions. The SearchResult class is contained in the same file.

2. receive.rb
   This class contains a function called listen which listens for incoming messages on the socket and spawns a new thread
   to deal with each message that is received.  The received messaged are parsed and given to the respond function.
   This looks at the message type and responds accordingly.

3. messages.rb
   This class contains a function for each of the messages that can possibly be sent by a node.  The desired message
   values are passed to these functions and a complete JSON message is returned, ready for sending.

4. routing.rb
   This class manages the routing table.  It is responsible for adding entries to and deleting entries from the routing
   table and creating a temporary routing table which includes its own information for sending.  In addition, using the
   findCloserNode function the routing table is searched for a node closer to a given node_id than the node itself.

5. indexing.rb
   This class is responsible for managing the node's indexes.  It can add indexes to the current list of indexes and can
   update the rank of an index if it is already present.  In addition, all indexes for a given keyword can be obtain.
   This functionality is used in responding to search requests.

6. hashing.rb
   This class contains a function which will return the hash of a given keyword.
