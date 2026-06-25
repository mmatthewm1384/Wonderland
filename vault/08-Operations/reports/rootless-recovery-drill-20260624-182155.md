# rootless-recovery-drill

Wed Jun 24 18:21:55 PDT 2026

## pre-state
NAME                   STATUS     SSH                VMTYPE    ARCH       CPUS    MEMORY    DISK      DIR
default                Running    127.0.0.1:49180    vz        aarch64    4       4GiB      100GiB    ~/.lima/default
wonderland-rootless    Running    127.0.0.1:60544    vz        aarch64    4       6GiB      80GiB     ~/.lima/wonderland-rootless

## stop rootless

## recover rootless
== Wonderland Rootless Recovery ==

== Current Lima State ==
NAME                   STATUS     SSH                VMTYPE    ARCH       CPUS    MEMORY    DISK      DIR
default                Running    127.0.0.1:49180    vz        aarch64    4       4GiB      100GiB    ~/.lima/default
wonderland-rootless    Stopped    127.0.0.1:60544    vz        aarch64    4       6GiB      80GiB     ~/.lima/wonderland-rootless

== Stop rootless if half-open ==

== Start rootless ==

== Verify rootless ==
PASS wonderland-rootless recovered

## post-status
Wonderland Status
=================

Universe
PASS universe             

Lima
WARN default legacy unavailable 
PASS wonderland-rootless  

Services
PASS wl-dns               
PASS wl-nats              
PASS wl-loki              
PASS wl-prometheus        
PASS wl-grafana           

Storage
PASS authority            external optional in light mode

Governance
PASS governance           

Doctor
Wonderland Doctor

PASS storage                  +10
PASS governance               +10
PASS universe                 +10
PASS lima-default             +10
PASS rootless                 +10
PASS dns                      +10
PASS nats                     +10
PASS loki                     +10
PASS prometheus               +10
PASS grafana                  +10

Health Score: 100/100
RESULT PASS

## post-doctor
