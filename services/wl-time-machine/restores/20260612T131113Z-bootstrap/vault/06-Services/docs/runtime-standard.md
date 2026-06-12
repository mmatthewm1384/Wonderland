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

## Governance Principle

This component may be destroyed and rebuilt without loss of authority.

Authority resides in:

- documented intent
- service definitions
- recovery procedures
- version-controlled governance records

Runtime state is disposable.
Authority is not.
