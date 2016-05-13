#!/bin/bash

# File : firewall.sh
# Author : Manuel Gonzales
# Date : Feb 02, 2016
# Script to set up the gateway firewall

###########################################################################################################
#USER DEFINED VARIABLES

#UTILITY PATH
IPT="iptables"

#CURRENT NETWORK INTERFACE
NETWORK_INTERFACE="wlp8s0"

#FIREWALL GATEWAY INTERFACE
GATEWAY_INTERFACE="enp7s0"

#CLIENT IP ADDRESS
CLIENT_IP_ADDR="192.168.1.2"

#GATEWAY IP ADDRESS
IP_ADDR="192.168.1.1"

#NETWORK SUBNET
NET_SUBNET_ADDR="192.168.0.0/24"
GATE_SUBNET_ADDR="192.168.0.0/24"

#LIST OF TCP SERVICES TO BE ALLOWED
TCP_IN_SERVICES=("80" "22")
TCP_OUT_SERVICES=("80" "443" "22")

#LIST OF UDP SERVICES TO BE ALLOWED
UDP_IN_SERVICES=("53")
UDP_OUT_SERVICES=("53")

#LIST OF ICMP TYPES TO BE ALLOWED
ICMP_IN_TYPES=("8" "0")
ICMP_OUT_TYPES=("8" "0")

#DHCP SERVER IP ADDRESS
DHCP_ADDR="192.168.0.0"

#DNS SERVER IP ADDRESS
DNS_ADDR="8.8.8.8"

#SET HIGH PORT START
MAXIMUM_USER_PORT="1024"



#END OF USER DEFINED VARIABLES
###########################################################################################################

if [[ $1 != "set" && $1 != "reset" ]] ; then
  error_exit " Correct Usage: firewall [set|reset]"
  exit
fi

#Flush all tables
if [ "$1" = "reset" ]
then
  $IPT --policy INPUT ACCEPT
  $IPT --policy OUTPUT ACCEPT
  $IPT --policy FORWARD ACCEPT
  $IPT -t nat --policy PREROUTING ACCEPT
  $IPT -t nat --policy OUTPUT ACCEPT
  $IPT -t nat --policy POSTROUTING ACCEPT
  $IPT -t mangle --policy PREROUTING ACCEPT
  $IPT -t mangle --policy OUTPUT ACCEPT

  $IPT --flush
  $IPT -t nat --flush
  $IPT -t mangle --flush

  $IPT -X
  $IPT -t nat -X
  $IPT -t mangle -X

  echo "Firewall rules reset!"

  #Enable Postrouting and Prerouting
  $IPT -t nat -A POSTROUTING -o $NETWORK_INTERFACE -j MASQUERADE
  #$IPT -t nat -A PREROUTING -i $NETWORK_INTERFACE -j DNAT --to $CLIENT_IP_ADDR

else

  #Set policy
  $IPT --policy INPUT DROP
  $IPT --policy OUTPUT DROP
  $IPT --policy FORWARD DROP

  $IPT -A PREROUTING -t mangle -p tcp --sport ftp-data -j TOS --set-tos Maximize-Throughput
  $IPT -A PREROUTING -t mangle -p tcp --sport ftp -j TOS --set-tos Minimize-Delay
  $IPT -A PREROUTING -t mangle -p tcp --sport ssh -j TOS --set-tos Minimize-Delay

  $IPT -A FORWARD -s $CLIENT_IP_ADDR -i $NETWORK_INTERFACE -j DROP #spoofing
  $IPT -A FORWARD -p tcp -m multiport --dport $MAXIMUM_USER_PORT:65535 --tcp-flags ALL SYN -j DROP #drop highports
  $IPT -A FORWARD -p tcp --tcp-flags ALL SYN,FIN -j DROP #syn , fin
  $IPT -A FORWARD -p tcp --tcp-flags ALL ALL -j DROP #xmas
  $IPT -A FORWARD -f -d $CLIENT_IP_ADDR -j ACCEPT #accept fragments

 #tcp inbound services
  for TCP_SERVICE in "${TCP_IN_SERVICES[@]}"
  do
    $IPT -t nat -A PREROUTING -i $NETWORK_INTERFACE -p tcp --dport $TCP_SERVICE -j DNAT --to $CLIENT_IP_ADDR:$TCP_SERVICE
    $IPT -A FORWARD -p tcp -m state --state NEW,ESTABLISHED --dport $TCP_SERVICE -i $NETWORK_INTERFACE -o $GATEWAY_INTERFACE -j ACCEPT
    $IPT -A FORWARD -p tcp -m state --state ESTABLISHED --sport $TCP_SERVICE -i $GATEWAY_INTERFACE -o $NETWORK_INTERFACE -j ACCEPT
  done

 #tcp outbound services
  for TCP_SERVICE in "${TCP_OUT_SERVICES[@]}"
  do
    $IPT -t nat -A PREROUTING -i $NETWORK_INTERFACE -p tcp --sport $TCP_SERVICE -j DNAT --to $CLIENT_IP_ADDR:$TCP_SERVICE
    $IPT -A FORWARD -p tcp -m state --state ESTABLISHED --sport $TCP_SERVICE -i $NETWORK_INTERFACE -o $GATEWAY_INTERFACE -j ACCEPT
    $IPT -A FORWARD -p tcp -m state --state NEW,ESTABLISHED --dport $TCP_SERVICE -i $GATEWAY_INTERFACE -o $NETWORK_INTERFACE -j ACCEPT
  done

 #udp inbound services
  for UDP_SERVICE in "${UDP_IN_SERVICES[@]}"
  do
    $IPT -t nat -A PREROUTING -i $NETWORK_INTERFACE -p udp --dport $UDP_SERVICE -j DNAT --to $CLIENT_IP_ADDR:$UDP_SERVICE
    $IPT -A FORWARD -p udp -m state --state NEW,ESTABLISHED --dport $UDP_SERVICE -i $NETWORK_INTERFACE -o $GATEWAY_INTERFACE -j ACCEPT
    $IPT -A FORWARD -p udp -m state --state ESTABLISHED --sport $UDP_SERVICE -i $GATEWAY_INTERFACE -o $NETWORK_INTERFACE -j ACCEPT
  done

 #udp outbound services
  for UDP_SERVICE in "${UDP_OUT_SERVICES[@]}"
  do
    $IPT -t nat -A PREROUTING -i $NETWORK_INTERFACE -p udp --sport $UDP_SERVICE -j DNAT --to $CLIENT_IP_ADDR:$UDP_SERVICE
    $IPT -A FORWARD -p udp -m state --state ESTABLISHED --sport $UDP_SERVICE -i $NETWORK_INTERFACE -o $GATEWAY_INTERFACE -j ACCEPT
    $IPT -A FORWARD -p udp -m state --state NEW,ESTABLISHED --dport $UDP_SERVICE -i $GATEWAY_INTERFACE -o $NETWORK_INTERFACE -j ACCEPT
  done

 #icmp inbound types
  for ICMP_TYPE in "${ICMP_IN_TYPES[@]}"
  do
    $IPT -t nat -A PREROUTING -i $NETWORK_INTERFACE -p icmp --icmp-type $ICMP_TYPE -j DNAT --to $CLIENT_IP_ADDR
    $IPT -A FORWARD -p icmp --icmp-type $ICMP_TYPE -i $NETWORK_INTERFACE -o $GATEWAY_INTERFACE -j ACCEPT
  done

 #icmp outbound types
  for ICMP_TYPE in "${ICMP_OUT_TYPES[@]}"
  do
    $IPT -A FORWARD -p icmp --icmp-type $ICMP_TYPE -i $GATEWAY_INTERFACE -o $NETWORK_INTERFACE -j ACCEPT
  done

fi
