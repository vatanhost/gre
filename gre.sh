#!/bin/bash
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)
echo -e "${CYAN}"
echo "===================================="
echo "        GitHub: vatanhost"
echo "   GRE Tunnel v1 Setup Script"
echo "===================================="
echo -e "${RESET}"

echo "Select server location:"
echo "1 - IRAN"
echo "2 - FOREIGN"
read -p "Enter 1 or 2: " LOCATION

read -p "Enter IRAN server IP: " IP_IRAN
read -p "Enter FOREIGN server IP: " IP_FOREIGN

if [[ "$LOCATION" == "1" ]]; then
    echo "[*] Running config for IRAN server..."

#    sudo iptables -t mangle -A POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1380
#    sudo ip link set dev eth0 mtu 1476

    sudo ip tunnel add vatan-m2 mode gre local $IP_IRAN remote $IP_FOREIGN ttl 255
    sudo ip link set vatan-m2 up
    sudo ip addr add 132.168.30.2/30 dev AbrDade-m2
   sysctl net.ipv4.ip_forward=1
iptables -t nat -A PREROUTING -p tcp --dport 22 -j DNAT --to-destination 132.168.30.2
iptables -t nat -A PREROUTING -j DNAT --to-destination 132.168.30.1
iptables -t nat -A POSTROUTING -j MASQUERADE 

elif [[ "$LOCATION" == "2" ]]; then
    echo "[*] Running config for FOREIGN server..."

    sudo ip tunnel add vatan-m2 mode gre local $IP_FOREIGN remote $IP_IRAN ttl 255
    sudo ip link set vatan-m2 up
    sudo ip addr add 132.168.30.1/30 dev vatan-m2

    sudo iptables -A INPUT --proto icmp -j DROP

else
    echo "[!] Invalid selection. Please enter 1 or 2."
    exit 1
fi
