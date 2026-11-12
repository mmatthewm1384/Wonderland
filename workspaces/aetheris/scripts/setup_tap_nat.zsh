#!/bin/zsh
set -euo pipefail

TAP_INTERFACE="tap0"
HOST_IP="192.168.100.1"
NETMASK="255.255.255.0"

echo "[*] Configuring host routing and NAT for $TAP_INTERFACE..."

# 1. Enable IP forwarding on macOS
sudo sysctl -w net.inet.ip.forwarding=1 >/dev/null

# 2. Configure IP address on the host TAP interface
sudo ifconfig "$TAP_INTERFACE" "$HOST_IP" netmask "$NETMASK" up

# 3. Configure pf (Packet Filter) NAT rules for internet sharing
# Find the active external interface (e.g., en0 for Wi-Fi or Ethernet)
EXT_IF=$(route get default | grep interface | awk '{print $2}')
echo "[*] Active external interface detected: $EXT_IF"

# Create a temporary pf rules file for NAT
PF_CONF="/tmp/pf_vm_nat.conf"
cat <<EOF > "$PF_CONF"
nat on $EXT_IF from ${HOST_IP%.*}.0/24 to any -> ($EXT_IF)
pass all
EOF

# Load and enable pf rules
sudo pfctl -ef "$PF_CONF" 2>/dev/null || sudo pfctl -f "$PF_CONF"
echo "[+]. NAT and packet filtering successfully configured."
