#!/usr/bin/env bash

set -euo pipefail

DEFAULT_GATEWAY="192.168.199.2"
DEFAULT_DNS=("1.1.1.1" "8.8.8.8" "192.168.199.2")

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <interface> <ip/cidr>"
    echo "Example: $0 ens33 192.168.1.100/24"
    exit 1
fi

INTERFACE="$1"
IP_ADDR="$2"

NETPLAN_FILE="/etc/netplan/99-custom-network.yaml"
SSH_CONFIG_FILE="/etc/ssh/sshd_config.d/99-custom.conf"

log() {
    echo "[INFO] $1"
}

# ------------------------------------------------------------------------------
# Configure Network
# ------------------------------------------------------------------------------

log "Configuring interface '$INTERFACE'..."

sudo tee "$NETPLAN_FILE" > /dev/null <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $INTERFACE:
      addresses:
        - $IP_ADDR
      routes:
        - to: default
          via: $DEFAULT_GATEWAY
      nameservers:
        addresses:
          - ${DEFAULT_DNS[0]}
          - ${DEFAULT_DNS[1]}
          - ${DEFAULT_DNS[2]}
EOF

log "Netplan configuration written to $NETPLAN_FILE"

sudo netplan generate
sudo netplan apply

log "Network configuration applied successfully"

# ------------------------------------------------------------------------------
# Configure SSH
# ------------------------------------------------------------------------------

log "Installing OpenSSH server..."

sudo apt-get update
sudo apt-get install -y openssh-server
sudo ssh-keygen -A

log "Configuring SSH..."

sudo tee "$SSH_CONFIG_FILE" > /dev/null <<EOF
PasswordAuthentication yes
PermitRootLogin yes
EOF

# Validate SSH configuration before restarting
sudo sshd -t

sudo systemctl enable --now ssh
sudo systemctl restart ssh

log "SSH configured successfully"
log "Root password authentication is enabled"