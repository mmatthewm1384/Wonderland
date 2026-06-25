# rootless-recovery-drill

Wed Jun 24 18:23:38 PDT 2026

## pre-state
NAME                   STATUS     SSH                VMTYPE    ARCH       CPUS    MEMORY    DISK      DIR
default                Running    127.0.0.1:49180    vz        aarch64    4       4GiB      100GiB    ~/.lima/default
wonderland-rootless    Running    127.0.0.1:60563    vz        aarch64    4       6GiB      80GiB     ~/.lima/wonderland-rootless

## stop rootless

## recover rootless
== Wonderland Rootless Recovery ==

== Current Lima State ==
NAME                   STATUS     SSH                VMTYPE    ARCH       CPUS    MEMORY    DISK      DIR
default                Running    127.0.0.1:49180    vz        aarch64    4       4GiB      100GiB    ~/.lima/default
wonderland-rootless    Stopped    127.0.0.1:60563    vz        aarch64    4       6GiB      80GiB     ~/.lima/wonderland-rootless

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

Wonderland Doctor
root: /Users/wonderland/Wonderland

vault                   PASS
registry integrity      FAIL
  Unknown wl command: registry
  
  Wonderland Operator CLI
  
  Usage:
    wl help
    wl status
    wl doctor
    wl repair
  
  Core:
    wl snapshot create|verify|restore-drill|list|doctor
    wl recovery doctor|drill|bundle|status
    wl storage attach|eject|force-eject|status|verify|doctor|authority
    wl governance doctor|status|report
    wl universe status|doctor|report
    wl services status|doctor|up|down|restart
  
  Runtime:
    wl runtime status|up|down|exec|doctor
    wl ephemeral list|doctor|status|repair|launch
    wl chaos status|start|stop|enable|disable|doctor
  
  Utilities:
    wl nav [governance|theomatrix|services|assets|reports]
    wl inspect [path]
    wl tree [path]
    wl path
    wl logs
    wl version
runtime drift           SKIP light mode
anon route              SKIP light mode
operations              FAIL
  Unknown wl command: operations
  
  Wonderland Operator CLI
  
  Usage:
    wl help
    wl status
    wl doctor
    wl repair
  
  Core:
    wl snapshot create|verify|restore-drill|list|doctor
    wl recovery doctor|drill|bundle|status
    wl storage attach|eject|force-eject|status|verify|doctor|authority
    wl governance doctor|status|report
    wl universe status|doctor|report
    wl services status|doctor|up|down|restart
  
  Runtime:
    wl runtime status|up|down|exec|doctor
    wl ephemeral list|doctor|status|repair|launch
    wl chaos status|start|stop|enable|disable|doctor
  
  Utilities:
    wl nav [governance|theomatrix|services|assets|reports]
    wl inspect [path]
    wl tree [path]
    wl path
    wl logs
    wl version
intelligence            FAIL
  Unknown wl command: intelligence
  
  Wonderland Operator CLI
  
  Usage:
    wl help
    wl status
    wl doctor
    wl repair
  
  Core:
    wl snapshot create|verify|restore-drill|list|doctor
    wl recovery doctor|drill|bundle|status
    wl storage attach|eject|force-eject|status|verify|doctor|authority
    wl governance doctor|status|report
    wl universe status|doctor|report
    wl services status|doctor|up|down|restart
  
  Runtime:
    wl runtime status|up|down|exec|doctor
    wl ephemeral list|doctor|status|repair|launch
    wl chaos status|start|stop|enable|disable|doctor
  
  Utilities:
    wl nav [governance|theomatrix|services|assets|reports]
    wl inspect [path]
    wl tree [path]
    wl path
    wl logs
    wl version
governance              PASS
storage authority       FAIL
  Wonderland Storage Doctor
  
  Wonderland Storage Authority
  
  Volume:      T7_Wonderland
  Path:        /Volumes/T7_Wonderland
  Mounted:     NO
  State:       DETACHED
  
  Open handles:
  
  Wonderland Storage Verify
  
  FAIL mounted: /Volumes/T7_Wonderland
  WARN missing: /Volumes/T7_Wonderland/Wonderland
  WARN missing: /Volumes/T7_Wonderland/media
  WARN missing: /Volumes/T7_Wonderland/media/music
  WARN missing: /Volumes/T7_Wonderland/media/torrents
  
  RESULT FAIL
authority backup        SKIP light mode
authority restore       SKIP light mode
recovery drill          SKIP light mode

RESULT FAIL
