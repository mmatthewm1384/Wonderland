#!/usr/bin/env bash
# core/vm_transport.sh: Host-to-VM orchestration bridge

set -euo pipefail

VM_NAME="${2:-}"
VM_CMD="${3:-doctor}"

# Mock Database mapping VM inventory (Expandable for Lima, QEMU, Vagrant)
get_vm_ssh_target() {
    case "$1" in
        webserver)  echo "appuser@192.168.64.10 -p 22" ;;
        database)   echo "dbuser@192.168.64.11 -p 22" ;;
        *)          echo "UNKNOWN" ;;
    esac
}

execute_vm_remote() {
    local target
    target=$(get_vm_ssh_target "$VM_NAME")
    
    if [ "$target" = "UNKNOWN" ]; then
        echo "[FAIL] VM Zone '$VM_NAME' is not defined in the workspace register." >&2
        exit 1
    fi

    echo "[+] Dispatching command to Guest VM [$VM_NAME]..."
    # Execute non-destructively through standard SSH loop
    ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no $target "source ~/.wl && wl $VM_CMD"
}

provision_guest_agent() {
    local target
    target=$(get_vm_ssh_target "$VM_NAME")
    
    echo "[*] Provisioning unified .wl core profile to Guest VM [$VM_NAME]..."
    # Idempotently inject the script baseline to the remote user's home folder
    scp -o StrictHostKeyChecking=no "${HOME}/.wl" "$target:~/.wl"
    ssh $target "mkdir -p ~/.wl-registry-v4 && touch ~/.wl-registry-v4/guest_state.json"
    echo "[+] Remote guest engine successfully provisioned."
}

case "${1:-}" in
    exec)      execute_vm_remote ;;
    bootstrap) provision_guest_agent ;;
esac
