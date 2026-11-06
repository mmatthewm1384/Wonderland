#!/bin/zsh
set -euo pipefail

# ====================================================================
# TaylorZone Encrypted APFS Sparsebundle Lifecycle Controller
# ====================================================================

DEFAULT_SPARSEBUNDLE_PATH="/Volumes/T7_VAULT_HOT/CrystalVault.sparsebundle"
MOUNT_POINT="/Volumes/TaylorZone"
PREMOUNTED_PATH="/Volumes/CrystalVault"
ACTION="${2:-mount}"

log_info() { echo "[+] $1"; }
log_warn() { echo "[!] $1"; }
log_err()  { echo "[-] $1" >&2; }

usage() {
    echo "Usage: $0 [path_to_sparsebundle] [mount|unmount|status]"
    echo "Default path: $DEFAULT_SPARSEBUNDLE_PATH"
    exit 1
}

# Dynamic volume resolution and pre-mount detection
resolve_vault() {
    # 1. Check if already mounted at /Volumes/CrystalVault or /Volumes/TaylorZone
    if mount | grep -q "on $MOUNT_POINT " || [[ -d "$PREMOUNTED_PATH" ]]; then
        echo "$PREMOUNTED_PATH"
        return 0
    fi

    local target_path="${1:-$DEFAULT_SPARSEBUNDLE_PATH}"

    # 2. Direct path check for sparsebundle file/directory
    if [[ -d "$target_path" ]]; then
        echo "$target_path"
        return 0
    fi

    log_warn "Primary path not found at: $target_path"
    log_info "Scanning /Volumes for active CrystalVault.sparsebundle locations..."

    # 3. Automated volume discovery across /Volumes
    local discovered_path
    discovered_path=$(find /Volumes -maxdepth 4 -name "CrystalVault.sparsebundle" -type d 2>/dev/null | head -n 1)

    if [[ -n "$discovered_path" && -d "$discovered_path" ]]; then
        echo "$discovered_path"
        return 0
    fi

    return 1
}

mount_vault() {
    local target_input="${1:-$DEFAULT_SPARSEBUNDLE_PATH}"
    local vault_source

    if ! vault_source=$(resolve_vault "$target_input"); then
        log_err "Error: CrystalVault.sparsebundle or pre-mounted vault was not found."
        log_err "Verify that your Samsung T7 or SanDisk Extreme SSD is connected and mounted."
        exit 1
    fi

    # Case A: Already mounted at /Volumes/CrystalVault
    if [[ "$vault_source" == "$PREMOUNTED_PATH" ]]; then
        log_info "CrystalVault is already attached at $PREMOUNTED_PATH."
        
        if [[ ! -d "$MOUNT_POINT" ]]; then
            log_info "Linking $PREMOUNTED_PATH to $MOUNT_POINT..."
            sudo mkdir -p "$(dirname "$MOUNT_POINT")"
            sudo ln -sfn "$PREMOUNTED_PATH" "$MOUNT_POINT"
        fi
    else
        # Case B: Unattached sparsebundle file requiring hdiutil attach
        log_info "Initiating attach process for sparsebundle at $vault_source..."

        if mount | grep -q "on $MOUNT_POINT "; then
            log_info "Volume already mounted at $MOUNT_POINT."
            exit 0
        fi

        log_info "Attaching volume and mounting to $MOUNT_POINT..."
        hdiutil attach "$vault_source" \
            -mountpoint "$MOUNT_POINT" \
            -nobrowse \
            -owners on
    fi

	# Enforce strict zero-trust permissions on mount root & shared assets
	TARGET_DIR="$MOUNT_POINT"
	if [[ -d "$PREMOUNTED_PATH" && ! -L "$MOUNT_POINT" ]]; then
	    TARGET_DIR="$PREMOUNTED_PATH"
	fi
	
	log_info "Enforcing strict POSIX permissions (700) on vault mount..."
	sudo chmod 700 "$TARGET_DIR"
	if [[ -d "$PREMOUNTED_PATH" ]]; then
	    sudo chmod 700 "$PREMOUNTED_PATH"
	fi
	
	# Provision required folder structure if missing
	if [[ ! -d "$TARGET_DIR/shared_assets" ]]; then
	    log_info "Creating initial shared_assets directory..."
	    sudo mkdir -p "$TARGET_DIR/shared_assets"
	    sudo chmod 700 "$TARGET_DIR/shared_assets"
	else
	    sudo chmod 700 "$TARGET_DIR/shared_assets"
	fi
	
	# Ensure Syncthing marker exists
	if [[ ! -d "$TARGET_DIR/shared_assets/.stfolder" ]]; then
	    sudo mkdir -p "$TARGET_DIR/shared_assets/.stfolder"
	    sudo chmod 700 "$TARGET_DIR/shared_assets/.stfolder"
	fi

    log_info "TaylorZone vault successfully mounted, linked, and verified."
}

unmount_vault() {
    log_info "Initiating unmount sequence..."

    if mount | grep -q "on $MOUNT_POINT "; then
        hdiutil detach "$MOUNT_POINT" -force || true
    fi
    
    if mount | grep -q "on $PREMOUNTED_PATH "; then
        hdiutil detach "$PREMOUNTED_PATH" -force || true
        log_info "Successfully detached CrystalVault."
    else
        log_info "No active detached mount locks found."
    fi
}

check_status() {
    if mount | grep -q "on $MOUNT_POINT " || [[ -d "$PREMOUNTED_PATH" ]]; then
        log_info "STATUS: Active Mount Present"
        mount | grep -E "on ($MOUNT_POINT|$PREMOUNTED_PATH) "
    else
        log_info "STATUS: Unmounted"
    fi
}

# --------------------------------------------------------------------
# Main Execution
# --------------------------------------------------------------------

case "$ACTION" in
    mount)
        mount_vault "${1:-$DEFAULT_SPARSEBUNDLE_PATH}"
        ;;
    unmount|detach|eject)
        unmount_vault
        ;;
    status)
        check_status
        ;;
    *)
        usage
        ;;
esac
