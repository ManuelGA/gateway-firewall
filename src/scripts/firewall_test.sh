

# File : firewall_test.sh
# Author : Manuel Gonzales
# Date : Feb 03, 2016
# Test Script


###########################################################################################################
#USER DEFINED VARIABLES

TCP_SERVICES=("22" "80" "443")
UDP_SERVICES=("53")
ICMP_TYPES=("0" "8")
FIREWALL_IP="192.168.0.2"
CLIENT_IP="192.168.1.2"

#END OF USER DEFINED VARIABLES
###########################################################################################################

RED='\033[0;31m'
NC='\033[0m'

#nmap test
echo -e "\n${RED}INITIATING FIREWALL TEST ${NC} \n"
echo -e "NMAP test\n"
nmap -v $FIREWALL_IP
echo -e ""

#port testing
echo -e "\n${RED}HIGH PORT TESTING ${NC} \n"
echo -e "ALL PACKETS SHOULD BE DROPPED \n"
hping3 $FIREWALL_IP -c 4 -S -p 2000
hping3 $FIREWALL_IP -c 4 -S -p 65534
hping3 $FIREWALL_IP -c 8 -S -p ++32768

echo -e "\n${RED}RESERVED PORT TESTING ${NC} \n"
echo -e "ALL PACKETS SHOULD BE DROPPED \n"
hping3 $FIREWALL_IP -c 3 -p ++137
hping3 $FIREWALL_IP -c 4 -S -p 111
hping3 $FIREWALL_IP -c 4 -S -p 115

#fragment testing
#echo -e "\n${RED}FRAGMENT TEST ${NC} \n"
#echo -e "ALL PACKETS SHOULD ARRIVE SUCCESFULLY \n"
#hping3 $FIREWALL_IP -c 4 -f

#tcp services testing
echo -e "\n${RED}TCP PORTS TEST ${NC} \n"
echo -e "ALL PACKETS SHOULD ARRIVE SUCCESFULLY \n"
for TCP_SERVICE in "${TCP_SERVICES[@]}"
  do
    hping3 $FIREWALL_IP -c 4 -k -S -p $TCP_SERVICE
  done

#udp services testing
echo -e "\n${RED}UDP PORTS TEST ${NC} \n"
echo -e "ALL PACKETS SHOULD ARRIVE SUCCESFULLY \n"
for UDP_SERVICE in "${UDP_SERVICES[@]}"
  do
    hping3 $FIREWALL_IP -c 4 -k --udp -p $UDP_SERVICE
  done

#icmp types testing
echo -e "\n${RED}ICMP TYPES TEST ${NC} \n"
echo -e "ALL PACKETS SHOULD ARRIVE SUCCESFULLY \n"
for ICMP_TYPE in "${ICMP_TYPES[@]}"
  do
    hping3 $FIREWALL_IP -c 4 -k --icmp --icmptype $ICMP_TYPE
  done

#telnet testing
echo -e "\n${RED}TELNET PORT TESTING ${NC} \n"
echo -e "ALL PACKETS SHOULD BE DROPPED \n"
hping3 $FIREWALL_IP -c 4 -p 23

#spoofing testing
echo -e "\n${RED}SPOOFTESTING ${NC} \n"
echo -e "ALL PACKETS SHOULD BE DROPPED \n"
hping3 $FIREWALL_IP -c 4 --spoof $CLIENT_IP

echo -e "${RED}TEST COMPLETE ${NC} \n"
