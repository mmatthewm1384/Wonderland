# Runtime Standard
<!-- id: runtime-standard-v4 -->

## Runtime

Wonderland uses containerd through nerdctl.

Docker is not a required runtime dependency.

## Commands

Runtime operations must go through:

```zsh
wl runtime ...
or:

wl-runtime ...
Standard
Engine: nerdctl
Runtime: containerd
Compose: nerdctl compose
Containers: wl-*
Networks: wonderland-* or wl-*
Volumes: wl-*-data
Status

state: active
version: 4
