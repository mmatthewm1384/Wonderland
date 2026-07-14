#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
VM="wonderland-rootless"
CPU="${WL_VM_CPU:-4}"
MEMORY="${WL_VM_MEMORY:-6GiB}"
DISK="${WL_VM_DISK:-80GiB}"

mkdir -p "$WL_HOME/config/runtime" "$WL_HOME/bin" "$WL_HOME/logs/runtime"

cat > "$WL_HOME/config/runtime/wonderland-rootless.lima.yaml" <<EOF
vmType: vz
arch: aarch64
cpus: ${CPU}
memory: ${MEMORY}
disk: ${DISK}

images:
  - location: "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-arm64.img"
    arch: "aarch64"

mounts:
  - location: "${WL_HOME}"
    writable: true

containerd:
  system: false
  user: true

provision:
  - mode: system
    script: |
      apt-get update
      apt-get install -y ca-certificates curl uidmap dbus-user-session slirp4netns fuse-overlayfs
  - mode: user
    script: |
      set -e
      if ! command -v nerdctl >/dev/null 2>&1; then
        VER="2.0.5"
        curl -fsSL -o /tmp/nerdctl.tgz "https://github.com/containerd/nerdctl/releases/download/v\${VER}/nerdctl-\${VER}-linux-arm64.tar.gz"
        mkdir -p ~/.local/bin
        tar -xzf /tmp/nerdctl.tgz -C ~/.local/bin nerdctl
      fi
      systemctl --user enable --now containerd
      ~/.local/bin/nerdctl version || true

probes:
  - script: |
      systemctl --user is-active containerd
EOF

if ! command -v limactl >/dev/null 2>&1; then
  echo "Installing Lima..."
  brew install lima
fi

if limactl list --format '{{.Name}}' | grep -qx "$VM"; then
  echo "VM already exists: $VM"
else
  limactl create --name="$VM" "$WL_HOME/config/runtime/wonderland-rootless.lima.yaml"
fi

cat > "$WL_HOME/bin/wl-rootless" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

VM="wonderland-rootless"

case "${1:-status}" in
  start)
    echo "Starting Wonderland Rootless VM..."
    limactl start "$VM"
    ;;
  stop)
    echo "Stopping Wonderland Rootless VM..."
    limactl stop "$VM"
    ;;
  restart)
    limactl stop "$VM" || true
    limactl start "$VM"
    ;;
  shell)
    limactl shell "$VM"
    ;;
  nerdctl)
    shift
    limactl shell "$VM" nerdctl "$@"
    ;;
  ps)
    limactl shell "$VM" nerdctl ps -a
    ;;
  images)
    limactl shell "$VM" nerdctl images
    ;;
  logs)
    limactl shell "$VM" journalctl --user -u containerd --no-pager -n 80
    ;;
  verify|doctor)
    echo "Wonderland Rootless Doctor"
    limactl list | grep "$VM" || { echo "FAIL vm missing"; exit 1; }
    limactl shell "$VM" systemctl --user is-active containerd | grep -q active && echo "PASS containerd"
    limactl shell "$VM" nerdctl version >/dev/null && echo "PASS nerdctl"
    limactl shell "$VM" nerdctl run --rm docker.io/library/alpine:3.20 echo PASS-runtime
    echo "RESULT PASS"
    ;;
  delete)
    echo "Refusing destructive delete without --force"
    exit 1
    ;;
  delete --force)
    limactl stop "$VM" || true
    limactl delete "$VM"
    ;;
  status|*)
    limactl list | grep -E "NAME|$VM" || true
    ;;
esac
EOF

chmod +x "$WL_HOME/bin/wl-rootless"

if ! grep -q 'Wonderland Rootless' "$HOME/.zshrc" 2>/dev/null; then
  cat >> "$HOME/.zshrc" <<EOF

# Wonderland Rootless
export PATH="\$HOME/Wonderland/bin:\$PATH"
alias wl-rootless-start='wl-rootless start'
alias wl-rootless-stop='wl-rootless stop'
alias wl-rootless-status='wl-rootless status'
alias wl-rootless-doctor='wl-rootless doctor'
alias wl-nerdctl='wl-rootless nerdctl'
EOF
fi

echo "Install complete."
echo "Run:"
echo "  source ~/.zshrc"
echo "  wl-rootless start"
echo "  wl-rootless doctor"
