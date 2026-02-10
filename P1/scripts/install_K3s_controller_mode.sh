#!/bin/bash

NODE_IP="192.168.56.110"
TOKEN_FILE="/vagrant_shared/node-token"

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y curl
# sudo apt-get install -y linux-headers-$(uname -r) build-essential dkms

curl -sfL https://get.k3s.io | \
	K3S_KUBECONFIG_MODE="644" \
	INSTALL_K3S_EXEC="server \
		--node-ip $NODE_IP \
            	--advertise-address $NODE_IP \
            	--tls-san $NODE_IP \
            	--flannel-iface eth1" \
        sh -

until [ -f /var/lib/rancher/k3s/server/node-token ]; do
    sleep 3
done

sudo tee "$TOKEN_FILE" < /var/lib/rancher/k3s/server/node-token >/dev/null
