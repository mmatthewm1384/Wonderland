# Wonderland Rootless Runtime Host

## Purpose

`wonderland-rootless` is the primary Wonderland Runtime Host.

It runs:

- `wl start`
- Wonderland Runtime services
- containerd / nerdctl
- Controller
- Registry
- Observability
- Chaos
- Matrix
- local development tools

It does **not** own OS image building long-term. Image building should become a Builder Service.

## Host Model

```text
macOS
  -> limactl
  -> wonderland-rootless
  -> wl runtime
Installed Tools

Core:

bash
zsh
git
curl
wget
jq
yq
python3
python3-venv
tmux
tree
rsync
sqlite3

Editors:

micro
vim
nano

Diagnostics:

htop
lsof
ncdu
nmap
strace
iproute2
net-tools
procps

Containers:

rootless containerd
nerdctl
fuse-overlayfs
slirp4netns
uidmap

Developer UX:

lazygit
gum
ripgrep
shellcheck
Runtime Environment
WONDERLAND_ROLE=runtime-host
WONDERLAND_PROFILE=development
WONDERLAND_HOST=wonderland-rootless
WONDERLAND_REPO=/Users/wonderland/Wonderland

