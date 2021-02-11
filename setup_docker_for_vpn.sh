#!/bin/bash

# Warning: run this script with root privileges, e.g.: sudo ./setup_docker_for_vpn.sh

# Get docker0 IP address
docker0_ip_address=$(ip -br addr show | grep docker0 | awk '{print $3}' | cut -d "/" -f 1)

echo "1. Set new IP mask"
cat <<EOF > /etc/docker/daemon.json
{
    "bip": "${docker0_ip_address}/24"
}
EOF

echo "2. Set ACCEPT policy for FORWARD chain"
iptables --policy FORWARD ACCEPT

echo "3. Stop docker service"
systemctl stop docker

echo "4. Flush all chains for 'nat' table"
iptables --table nat --flush

echo "5. Install 'bridge-utils' package if necessary"
if [[ -z "$(apt list bridge-utils 2>/dev/null | grep installed)" ]]; then
    apt install -y bridge-utils
fi

echo "6. Stop and remove docker0 interface"
ifconfig docker0 down
brctl delbr docker0

echo "7. Restart docker service"
systemctl restart docker
