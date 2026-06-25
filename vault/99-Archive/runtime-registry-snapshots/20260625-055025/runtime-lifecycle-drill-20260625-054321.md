# runtime-lifecycle-drill

Thu Jun 25 05:43:21 PDT 2026

## pre-state
NAME                   STATUS     SSH                VMTYPE    ARCH       CPUS    MEMORY    DISK      DIR
default                Running    127.0.0.1:49245    vz        aarch64    4       4GiB      100GiB    ~/.lima/default
wonderland-rootless    Running    127.0.0.1:49280    vz        aarch64    4       6GiB      80GiB     ~/.lima/wonderland-rootless

## stop rootless first pass
== Stopping Wonderland Rootless Runtime ==

## stop rootless second pass
== Stopping Wonderland Rootless Runtime ==
PASS wonderland-rootless already stopped

## start
== Starting Wonderland Rootless Runtime ==
PASS wonderland-rootless primary

== Starting Legacy Default Runtime ==
WARN default legacy unavailable

== Status ==
Wonderland Status
=================

Universe
FAIL universe             

Lima
WARN default legacy unavailable 
PASS wonderland-rootless  

Services
FAIL wl-dns               
FAIL wl-nats              
FAIL wl-loki              
FAIL wl-prometheus        
PASS wl-grafana           

Storage
PASS authority            external optional in light mode

Governance
PASS governance           

Doctor
Wonderland Doctor

PASS storage                  +10
PASS governance               +10
FAIL universe                 +0
PASS lima-default             +10
PASS rootless                 +10
FAIL dns                      +0
FAIL nats                     +0
FAIL loki                     +0
FAIL prometheus               +0
PASS grafana                  +10

Health Score: 50/100
RESULT FAIL

## status
Wonderland Status
=================

Universe
FAIL universe             

Lima
PASS default legacy       
PASS wonderland-rootless  

Services
FAIL wl-dns               
FAIL wl-nats              
FAIL wl-loki              
FAIL wl-prometheus        
PASS wl-grafana           

Storage
PASS authority            external optional in light mode

Governance
PASS governance           

Doctor
Wonderland Doctor

PASS storage                  +10
PASS governance               +10
FAIL universe                 +0
PASS lima-default             +10
PASS rootless                 +10
FAIL dns                      +0
FAIL nats                     +0
PASS loki                     +10
FAIL prometheus               +0
PASS grafana                  +10

Health Score: 60/100
RESULT FAIL

## doctor

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
