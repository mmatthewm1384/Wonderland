# runtime-registry-recovery-drill

Thu Jun 25 05:50:25 PDT 2026

## pre-verify
PASS runtime registry certified

## snapshot
PASS runtime registry snapshot
SNAPSHOT=/Users/wonderland/Wonderland/vault/99-Archive/runtime-registry-snapshots/20260625-055025

## corrupt-test
FAIL invalid runtime registry
PASS corruption detected

## restore
PASS runtime registry restored
SNAPSHOT=/Users/wonderland/Wonderland/vault/99-Archive/runtime-registry-snapshots/20260625-055025

## post-verify
PASS runtime registry certified

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
