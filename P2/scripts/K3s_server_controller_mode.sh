#!/bin/bash

SERVER_NODE_IP="192.168.56.110"

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y curl
# sudo apt-get install -y linux-headers-$(uname -r) build-essential dkms


# - - - [ K3s-Server_mode ] - - -
curl -sfL https://get.k3s.io | \
	K3S_KUBECONFIG_MODE="644" \
	INSTALL_K3S_EXEC="server \
		--node-ip $SERVER_NODE_IP \
        --advertise-address $SERVER_NODE_IP \
        --tls-san $SERVER_NODE_IP \
        --flannel-iface eth1" \
    sh -


# - - - [ Docker for app containers ] - - -
# - [ Dependencies ] -
sudo apt-get update -y
sudo apt-get install -y \
  ca-certificates \
  gnupg \
  lsb-release \
  apt-transport-https \
  software-properties-common

# - [ Docker GPG Key + Depot ] -
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list

sudo apt-get update -y

# - [ Installation Docker + start at launch ] -
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker

# - [ Add vagrant User to docker group ] - avoid sudo 
sudo usermode -aG docker $USER
sudo systemctl restart docker


# - - - [ Build Docker Image (Apps) ] - - -












