#!/usr/bin/env bash

set -euo pipefail

DEFAULT_GATEWAY="192.168.199.2"
DEFAULT_DNS="1.1.1.1 8.8.8.8 192.168.199.2"

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <connection-name> <ip/cidr>"
    echo "Example: $0 'VM Network' 192.168.1.100/24"
    exit 1
fi

CONN="$1"
IP_ADDR="$2"

log() {
    echo "[INFO] $(tput setaf 7)$1$(tput sgr0)"
}

#----------------------------------------------------------------------------------
# Configure IPv4
#----------------------------------------------------------------------------------
nmcli connection modify "$CONN" \
    ipv4.method dhcp \
    ipv4.addresses "$IP_ADDR" \
    ipv4.gateway "$DEFAULT_GATEWAY" \
    ipv4.dns "$DEFAULT_DNS"

log "IPv4 configuration applied"

#----------------------------------------------------------------------------------
# Restart Connection
#----------------------------------------------------------------------------------
log "Restarting connection '$CONN'..."

nmcli connection down "$CONN"
nmcli connection up "$CONN"

log "Configuration applied successfully"