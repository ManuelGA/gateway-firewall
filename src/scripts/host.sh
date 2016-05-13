###########################################################################################################
#USER DEFINE VARIABLES

#CURRENT NETWORK INTERFACE
NETWORK_INTERFACE="wlp2s0"

#FIREWALL GATEWAY INTERFACE
GATEWAY_INTERFACE="enp3s0"

#NEW IP ADRESS / MASK
IP_ADDR="192.168.1.2/24"

#FIREWALL GATEWAY ADDRESS
GATEWAY_ADDR="192.168.1.1"

#PREFERRED DNS SERVERS
DNS1="8.8.8.8"
DNS2="8.8.4.4"

#END OF USER DEFINED VARIABLES
###########################################################################################################S

DNS="nameserver"

#set interfaces
ip link set $NETWORK_INTERFACE down
ip link set $GATEWAY_INTERFACE up
ip addr flush dev $GATEWAY_INTERFACE

#set up DNS
echo -e "$DNS $DNS1\n$DNS $DNS2" > /etc/resolv.conf

#set ip address
ip addr add $IP_ADDR dev $GATEWAY_INTERFACE

#set gateway route
ip route add default via $GATEWAY_ADDR
