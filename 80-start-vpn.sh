#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source .env

if ! ./misc/gcloud.sh compute firewall-rules describe allow-wireguard &>/dev/null; then
./misc/gcloud.sh compute firewall-rules create allow-wireguard \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=udp:51820,tcp:80,tcp:443 \
    --target-tags=wireguard-server \
    --source-ranges=0.0.0.0/0
fi

TAGS=$(./misc/gcloud.sh compute instances describe wg-vm \
    --zone=${GCP_VM_ZONE} \
    --format="get(tags.items)")

if [[ ! "$TAGS" =~ wireguard-server ]]; then
./misc/gcloud.sh compute instances add-tags wg-vm \
    --tags=wireguard-server \
    --zone=${GCP_VM_ZONE}
fi


./ssh-to-vm.sh <<EOF
set -eu
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo apt update
sudo apt dist-upgrade

# Install Docker only if not already installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh ./get-docker.sh
else
    echo "Docker already installed"
fi



#
sudo systemctl start docker
sudo usermod -aG docker $VM_USER
docker run hello-world

if [[ ! -d wireguard-container ]]; then
  git clone --branch v1.0 https://github.com/ludwigprager/wireguard-container.git
fi

sudo apt -y install wireguard wireguard-tools
echo "Creating wg server config"
./wireguard-container/create-server-config.sh
echo "Creating wg client configs"
./wireguard-container/create-configs.sh
#Todo warum sudo
sudo ./wireguard-container/start.sh

# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1

# Get external interface
EXT_IFACE=\$(ip route | grep default | awk '{print \$5}')

# Add NAT for WireGuard subnet
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o \$EXT_IFACE -j MASQUERADE

# Allow forwarding through WireGuard
sudo iptables -A FORWARD -i wg0 -j ACCEPT
sudo iptables -A FORWARD -o wg0 -j ACCEPT

## Verify
#echo "Rules applied. External interface: \$EXT_IFACE"
#sudo iptables -t nat -L POSTROUTING -v -n | grep 10.0.0



#if [ "$(docker ps -aq -f name=imgserver)" ]; then
#TODO hack
docker rm -f imgserver || true
docker run -d \
  --name imgserver \
  -p 80:80 \
  -v ./wireguard-container/config-files/:/usr/share/nginx/html:ro \
  nginx:alpine
#fi

EOF

ADDRESS=$(kubectl get instances wg-vm  -o json | jq -r .status.atProvider.networkInterface[0].accessConfig[].natIp)

echo http://$ADDRESS/client-1.conf.png
