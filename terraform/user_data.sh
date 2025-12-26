#!/bin/bash
set -e

# Update system packages
apt-get update
apt-get upgrade -y

# Install dependencies
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list
apt-get update

# Install Docker
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Create admin user with password
useradd -m -s /bin/bash ${admin_username} || true

# Set password for admin user
echo "${admin_username}:${admin_password}" | chpasswd

# Add admin user to docker group
usermod -aG docker ${admin_username}

# Create docker group if it doesn't exist
groupadd docker || true

# Enable docker socket for group
newgrp docker || true

# Configure Docker daemon for Swarm
