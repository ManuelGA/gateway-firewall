###########################################################################################################
#USER DEFINE VARIABLES

#CURRENT NETWORK INTERFACE
NETWORK_INTERFACE="wlp8s0"

#FIREWALL GATEWAY INTERFACE
GATEWAY_INTERFACE="enp7s0"

#CURRENT IP ADDRESS
NET_IP_ADDR="192.168.0.2"

#NETWORK SUBNET
NET_SUBNET_ADDR="192.168.0.0/24"
GATE_SUBNET_ADDR="192.168.0.0/24"

#NEW IP ADDRESS AND MASK
IP_ADDR="192.168.1.1"
MASK="24"

#PREFERRED DNS SERVERS
DNS1="8.8.8.8"
DNS2="8.8.4.4"

#END OF USER DEFINED VARIABLES
###########################################################################################################

DNS="nameserver"

#set interface
ip link set $GATEWAY_INTERFACE up
ip addr flush dev $GATEWAY_INTERFACE

#set up DNS
echo -e "$DNS $DNS1\n$DNS $DNS2" > /etc/resolv.conf

#allow forwarding
echo "1" >/proc/sys/net/ipv4/ip_forward

#set ip address
ip addr add $IP_ADDR/$MASK dev $GATEWAY_INTERFACE

#set gateway routing
#ip route add $NET_SUBNET_ADDR via $NET_IP_ADDR dev $NETWORK_INTERFACE
#ip route add $GATE_SUBNET_ADDR via $IP_ADDR dev $GATEWAY_INTERFACE

iptables -t nat -A POSTROUTING -o $NETWORK_INTERFACE -j MASQUERADE
