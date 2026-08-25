#!/usr/bin/env bash

set -euo pipefail

echo "=== Update OS ==="

sudo apt update
sudo apt full-upgrade -y


echo "=== Remove SSH host keys ==="

sudo rm -f /etc/ssh/ssh_host_*


echo "=== Reset machine ID ==="

sudo truncate -s 0 /etc/machine-id
sudo rm -f /var/lib/dbus/machine-id


echo "=== Clean logs ==="

sudo journalctl --rotate
sudo journalctl --vacuum-time=1s

sudo find /var/log -type f -exec truncate -s 0 {} \;


echo "=== Clean temporary files ==="

sudo find /tmp -mindepth 1 -delete
sudo find /var/tmp -mindepth 1 -delete


echo "=== Clean APT ==="

sudo apt autoremove -y
sudo apt clean
sudo apt autoclean
sudo rm -rf /var/lib/apt/lists/*


echo "=== Cleanup complete ==="