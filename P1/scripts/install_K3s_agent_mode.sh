#!/bin/bash

NODE_IP_SERVER="192.168.56.110"
TOKEN_FILE="/vagrant_shared/node-token"

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y curl
sudo apt-get install -y nfs-kernel-server
# sudo apt-get install -y linux-headers-$(uname -r) build-essential dkms

until [ -f "$TOKEN_FILE" ]; do
    sleep 3
done

K3S_TOKEN=$(cat "$TOKEN_FILE")

curl -sfL https://get.k3s.io | \
	K3S_URL="https://$NODE_IP_SERVER:6443" \
	K3S_TOKEN="$K3S_TOKEN" \
	INSTALL_K3S_EXEC="agent \
		--node-ip 192.168.56.111 \
        	--flannel-iface eth1" \
    	sh -

