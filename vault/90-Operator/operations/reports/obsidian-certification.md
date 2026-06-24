# Obsidian Operator Certification

Generated: Sun Jun 21 20:49:13 PDT 2026

## Checks

- PASS wl exists
- PASS wl-obsidian exists
- PASS operator home
- PASS operator intents
- PASS obsidian status
- PASS obsidian verify
- PASS obsidian list
- INFO wl doctor runtime state
  == Wonderland Doctor ==
  PASS wl-home
  PASS wl-bin
  PASS reports-dir
  
  Wonderland Storage Doctor
  
  Wonderland Storage Authority
  
  Volume:      T7_Wonderland
  Path:        /Volumes/T7_Wonderland
  Mounted:     NO
  State:       DETACHED
  
  Open handles:
  
  Wonderland Storage Verify
  
  FAIL mounted: /Volumes/T7_Wonderland
  WARN missing: /Volumes/T7_Wonderland/Wonderland-v4
  WARN missing: /Volumes/T7_Wonderland/media
  WARN missing: /Volumes/T7_Wonderland/media/music
  WARN missing: /Volumes/T7_Wonderland/media/torrents
  
  RESULT FAIL
  
  PASS nerdctl
  WARN wl-dns not-running
  WARN wl-nats not-running
  WARN wl-prometheus not-running
  WARN wl-grafana not-running
  WARN wl-loki not-running
  RESULT PASS
  
  PASS snapshot latest exists
  /Users/wonderland/Wonderland/vault/08-Operations/snapshots/snapshot-20260621-065245
  
  PASS=68
  FAIL=27
  
  Wonderland Universe Doctor
  
  Wonderland Universe Status
  
  Root:  /Users/wonderland/Wonderland
  Mode:  light
  
  Authority
  PASS mode                   
  PASS storage                
  FAIL storage authority      
  
  Governance
  PASS governance             
  PASS recovery               
  PASS snapshot               
  
  Runtime
  FAIL dns                    
  FAIL nats                   
  FAIL observability          
  
  Capability
  WARN media                  unavailable in current mode
  WARN torrent                unavailable in current mode
  
  RESULT FAIL
  
  Recommendations
  WARN universe certification status missing
  
  RESULT PASS
  
  RESULT FAIL

## Result

Obsidian operator layer is certified if all Obsidian checks are PASS. Runtime/storage failures are reported separately.
