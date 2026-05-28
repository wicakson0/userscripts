#!/usr/bin/env bash

set -euo pipefail

# --- Configuration ---
# Keep Gateway and DNS hardcoded as requested
DEFAULT_GATEWAY="192.168.199.2"
DEFAULT_DNS="1.1.1.1 8.8.8.8 192.168.199.2"

CONN="$1"
IP_ADDR="$2"

# --- Logging Function ---
# Adds color coding for better terminal readability
log() {
	echo "[INFO] $(tput setaf 7)$1$(tput sgr0)"
}

# --- Input Validation ---
if [[ $# -ne 2 ]]; then
	echo "Usage: $0 <connection-name> <ip/cidr>"
	echo "Example: $0 'VM Network' 192.168.1.100/24"
	exit 1
fi

#----------------------------------------------------------------------------------
# Setting IP Method to Manual
#----------------------------------------------------------------------------------
nmcli connection modify "$CONN" ipv4.method manual
log "IP Method Set to Manual"

#----------------------------------------------------------------------------------
# Setting IP Address
#----------------------------------------------------------------------------------
nmcli connection modify "$CONN" ipv4.addresses "$IP_ADDR"
log "IP Address Set to $IP_ADDR"

#----------------------------------------------------------------------------------
# Setting Gateway
#----------------------------------------------------------------------------------
nmcli connection modify "$CONN" ipv4.gateway "$DEFAULT_GATEWAY"
log "Gateway Set to $DEFAULT_GATEWAY"

#----------------------------------------------------------------------------------
# Setting DNS
#----------------------------------------------------------------------------------
nmcli connection modify "$CONN" ipv4.dns "$DEFAULT_DNS"
log "DNS Set to $DEFAULT_DNS" 

#----------------------------------------------------------------------------------
# Apply Settings
#----------------------------------------------------------------------------------
log "Restarting connection '$CONN'..."
nmcli connection down "$CONN"
nmcli connection up "$CONN"
log "Configuration applied successfully."
