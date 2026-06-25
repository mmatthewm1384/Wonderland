# portability-hardening

ROOT=/Users/wonderland/Wonderland
BACKUP=/Users/wonderland/Wonderland/.backup/portability-hardening-20260625-060643

PATCH scripts/install/repair-wl-nav-dispatch.sh
PATCH scripts/install/wl-operator-layer-migrate.sh
PATCH scripts/install/wl-phase-d-native-contract-reader.sh
PATCH ephemeral/bin/wl-chaos-menubar
PATCH ephemeral/compose/matrix-atom-slam/compose.yml
PATCH bin/wl-verify-paths
REFRESH runtime index

## verification
FAIL active hardcoded authority paths
/Users/wonderland/Wonderland/registries/root-registry.json:4:    "authority": "/Users/wonderland/Wonderland",
/Users/wonderland/Wonderland/.wl-registry:3:  "generated_from": "/Users/wonderland/Wonderland/intelligence/obsidian/00-Core/Governance.md",
/Users/wonderland/Wonderland/.wl-registry:71:        "path": "/Users/wonderland/Wonderland/bin/wl-body-time",
/Users/wonderland/Wonderland/.wl-registry:76:        "path": "/Users/wonderland/Wonderland/bin/wl-chrono",
/Users/wonderland/Wonderland/.wl-registry:81:        "path": "/Users/wonderland/Wonderland/bin/wl-chrono-v2",
/Users/wonderland/Wonderland/.wl-registry:86:        "path": "/Users/wonderland/Wonderland/bin/wl-chronosphere",
/Users/wonderland/Wonderland/.wl-registry:91:        "path": "/Users/wonderland/Wonderland/bin/wl-chronosphere-app",
/Users/wonderland/Wonderland/.wl-registry:96:        "path": "/Users/wonderland/Wonderland/bin/wl-chronosphere-install",
/Users/wonderland/Wonderland/.wl-registry:101:        "path": "/Users/wonderland/Wonderland/bin/wl-chronosphere-v2",
/Users/wonderland/Wonderland/.wl-registry:106:        "path": "/Users/wonderland/Wonderland/bin/wl-chronosphere-v2-install",
/Users/wonderland/Wonderland/.wl-registry:111:        "path": "/Users/wonderland/Wonderland/bin/wl-context",
/Users/wonderland/Wonderland/.wl-registry:116:        "path": "/Users/wonderland/Wonderland/bin/wl-disposable",
/Users/wonderland/Wonderland/.wl-registry:121:        "path": "/Users/wonderland/Wonderland/bin/wl-doctor",
/Users/wonderland/Wonderland/.wl-registry:126:        "path": "/Users/wonderland/Wonderland/bin/wl-env-clean",
/Users/wonderland/Wonderland/.wl-registry:131:        "path": "/Users/wonderland/Wonderland/bin/wl-ga-plus-install",
/Users/wonderland/Wonderland/.wl-registry:136:        "path": "/Users/wonderland/Wonderland/bin/wl-governance",
/Users/wonderland/Wonderland/.wl-registry:141:        "path": "/Users/wonderland/Wonderland/bin/wl-intel",
/Users/wonderland/Wonderland/.wl-registry:146:        "path": "/Users/wonderland/Wonderland/bin/wl-knowledge-dropin",
/Users/wonderland/Wonderland/.wl-registry:151:        "path": "/Users/wonderland/Wonderland/bin/wl-link-runtime",
/Users/wonderland/Wonderland/.wl-registry:156:        "path": "/Users/wonderland/Wonderland/bin/wl-mind-body",
/Users/wonderland/Wonderland/.wl-registry:161:        "path": "/Users/wonderland/Wonderland/bin/wl-mind-body-app",
/Users/wonderland/Wonderland/.wl-registry:166:        "path": "/Users/wonderland/Wonderland/bin/wl-mind-body-install",
/Users/wonderland/Wonderland/.wl-registry:171:        "path": "/Users/wonderland/Wonderland/bin/wl-path-fix",
/Users/wonderland/Wonderland/.wl-registry:176:        "path": "/Users/wonderland/Wonderland/bin/wl-proxy",
/Users/wonderland/Wonderland/.wl-registry:181:        "path": "/Users/wonderland/Wonderland/bin/wl-registry",
/Users/wonderland/Wonderland/.wl-registry:186:        "path": "/Users/wonderland/Wonderland/bin/wl-services",
/Users/wonderland/Wonderland/.wl-registry:191:        "path": "/Users/wonderland/Wonderland/bin/wl-snapshot",
/Users/wonderland/Wonderland/.wl-registry:196:        "path": "/Users/wonderland/Wonderland/bin/wl-start",
/Users/wonderland/Wonderland/.wl-registry:201:        "path": "/Users/wonderland/Wonderland/bin/wl-status",
/Users/wonderland/Wonderland/.wl-registry:206:        "path": "/Users/wonderland/Wonderland/bin/wl-stop",
/Users/wonderland/Wonderland/.wl-registry:211:        "path": "/Users/wonderland/Wonderland/bin/wl-vault",
/Users/wonderland/Wonderland/.wl-registry:218:        "path": "/Users/wonderland/Wonderland/core/consolidate.sh",
/Users/wonderland/Wonderland/.wl-registry:224:        "path": "/Users/wonderland/Wonderland/core/doctor.sh",
/Users/wonderland/Wonderland/.wl-registry:230:        "path": "/Users/wonderland/Wonderland/core/doctor_security.sh",
/Users/wonderland/Wonderland/.wl-registry:236:        "path": "/Users/wonderland/Wonderland/core/doctor_volume_alignment.sh",
/Users/wonderland/Wonderland/.wl-registry:244:        "path": "/Users/wonderland/Wonderland",
/Users/wonderland/Wonderland/.wl-registry:253:        "path": "/Users/wonderland/Wonderland/logs/context",
/Users/wonderland/Wonderland/.wl-registry:258:        "path": "/Users/wonderland/Wonderland/logs/governance",
/Users/wonderland/Wonderland/.wl-registry:263:        "path": "/Users/wonderland/Wonderland/logs/registry",
/Users/wonderland/Wonderland/.wl-registry:268:        "path": "/Users/wonderland/Wonderland/logs/services",
/Users/wonderland/Wonderland/.wl-registry:273:        "path": "/Users/wonderland/Wonderland/logs/snapshot",
/Users/wonderland/Wonderland/.wl-registry:280:        "path": "/Users/wonderland/Wonderland/data/archive",
/Users/wonderland/Wonderland/.wl-registry:285:        "path": "/Users/wonderland/Wonderland/data/backups",
/Users/wonderland/Wonderland/.wl-registry:290:        "path": "/Users/wonderland/Wonderland/data/knowledge",
/Users/wonderland/Wonderland/.wl-registry:295:        "path": "/Users/wonderland/Wonderland/data/media",
/Users/wonderland/Wonderland/.wl-registry:300:        "path": "/Users/wonderland/Wonderland/data/models",
/Users/wonderland/Wonderland/.wl-registry:305:        "path": "/Users/wonderland/Wonderland/data/snapshots",
/Users/wonderland/Wonderland/.wl-registry:310:        "path": "/Users/wonderland/Wonderland/data/vaults",
/Users/wonderland/Wonderland/.wl-registry:317:        "path": "/Users/wonderland/Wonderland/tools/bin",
/Users/wonderland/Wonderland/.wl-registry:324:        "path": "/Users/wonderland/Wonderland/intelligence/obsidian",
/Users/wonderland/Wonderland/.wl-registry:331:        "path": "/Users/wonderland/Wonderland/secrets/.anthropic_token_vault",
/Users/wonderland/Wonderland/.wl-registry:338:        "path": "/Users/wonderland/Wonderland/secrets/.gemini_token_vault",
/Users/wonderland/Wonderland/.wl-registry:345:        "path": "/Users/wonderland/Wonderland/secrets/.github_token_vault",
/Users/wonderland/Wonderland/.wl-registry:352:        "path": "/Users/wonderland/Wonderland/secrets/.openai_token_vault",
/Users/wonderland/Wonderland/.wl-registry:359:        "path": "/Users/wonderland/Wonderland/secrets/.vault_token",
/Users/wonderland/Wonderland/.wl-registry:366:        "path": "/Users/wonderland/Wonderland/secrets/.wandb_token_vault",
/Users/wonderland/Wonderland/.wl-registry:373:        "path": "/Users/wonderland/Wonderland/secrets/openai_rights_manifest.json",
/Users/wonderland/Wonderland/.wl-registry:380:        "path": "/Users/wonderland/Wonderland/secrets/wl-registry.json",
/Users/wonderland/Wonderland/intents/ai-provider-vault-loading-test.intent.json:11:    "context_root": "/Users/wonderland/Wonderland",
/Users/wonderland/Wonderland/intents/ai-provider-vault-loading-test.intent.json:12:    "vault_root": "/Users/wonderland/Wonderland/vault"
/Users/wonderland/Wonderland/vault/05-Registry/runtime/runtime-certification-index.json:8:  "registry": "/Users/wonderland/Wonderland/vault/05-Registry/runtime/rootless-runtime.json"
/Users/wonderland/Wonderland/vault/09-Governance/standards/wl-gov-004-authority-persistence-standard.md:16:/Users/wonderland/Wonderland
/Users/wonderland/Wonderland/vault/09-Governance/standards/wl-gov-006-legacy-import-archive-standard.md:18:/Users/wonderland/Wonderland
/Users/wonderland/Wonderland/vault/vault-map.json:4:  "root": "/Users/wonderland/Wonderland/vault",
/Users/wonderland/Wonderland/vault/07-Operations/chrono/branches/future-wil-v1.branch.json:6:  "root": "/Users/wonderland/Wonderland"
/Users/wonderland/Wonderland/vault/07-Operations/recovery/certifications/service-recovery-certifications.json:8:      "definition": "/Users/wonderland/Wonderland/vault/06-Services/definitions/wl-anon-scraper.service.json"
/Users/wonderland/Wonderland/vault/07-Operations/recovery/certifications/service-recovery-certifications.json:14:      "definition": "/Users/wonderland/Wonderland/vault/06-Services/definitions/wl-anon-tor.service.json"
/Users/wonderland/Wonderland/vault/07-Operations/recovery/certifications/service-recovery-certifications.json:20:      "definition": "/Users/wonderland/Wonderland/vault/06-Services/definitions/wl-document-cleaner.service.json"
/Users/wonderland/Wonderland/vault/07-Operations/recovery/certifications/service-recovery-certifications.json:26:      "definition": "/Users/wonderland/Wonderland/vault/06-Services/definitions/wl-torrent-vpn.service.json"
/Users/wonderland/Wonderland/vault/07-Operations/recovery/certifications/service-recovery-certifications.json:32:      "definition": "/Users/wonderland/Wonderland/vault/06-Services/definitions/wl-torrent-client.service.json"
/Users/wonderland/Wonderland/vault/07-Operations/recovery/certifications/service-recovery-certifications.json:38:      "definition": "/Users/wonderland/Wonderland/vault/06-Services/definitions/wl-nats.service.json"
/Users/wonderland/Wonderland/vault/07-Operations/recovery/certifications/service-recovery-certifications.json:44:      "definition": "/Users/wonderland/Wonderland/vault/06-Services/definitions/wl-prometheus.service.json"
/Users/wonderland/Wonderland/vault/07-Operations/recovery/certifications/service-recovery-certifications.json:50:      "definition": "/Users/wonderland/Wonderland/vault/06-Services/definitions/wl-loki.service.json"
/Users/wonderland/Wonderland/vault/07-Operations/recovery/certifications/service-recovery-certifications.json:56:      "definition": "/Users/wonderland/Wonderland/vault/06-Services/definitions/wl-grafana.service.json"
/Users/wonderland/Wonderland/vault/07-Operations/recovery/certifications/service-recovery-certifications.json:62:      "definition": "/Users/wonderland/Wonderland/vault/06-Services/definitions/wl-dns.service.json"
/Users/wonderland/Wonderland/vault/07-Operations/secrets/inventory/secrets-inventory.txt:1:/Users/wonderland/Wonderland/secrets/.wandb_token_vault
/Users/wonderland/Wonderland/vault/07-Operations/secrets/inventory/secrets-inventory.txt:2:/Users/wonderland/Wonderland/secrets/.github_token_vault
/Users/wonderland/Wonderland/vault/07-Operations/secrets/inventory/secrets-inventory.txt:3:/Users/wonderland/Wonderland/secrets/proxy/tor.env
/Users/wonderland/Wonderland/vault/07-Operations/secrets/inventory/secrets-inventory.txt:4:/Users/wonderland/Wonderland/secrets/proxy/tor.env.example
/Users/wonderland/Wonderland/vault/07-Operations/secrets/inventory/secrets-inventory.txt:5:/Users/wonderland/Wonderland/secrets/openai_rights_manifest.json
/Users/wonderland/Wonderland/vault/07-Operations/secrets/inventory/secrets-inventory.txt:6:/Users/wonderland/Wonderland/secrets/.vault_token
/Users/wonderland/Wonderland/vault/07-Operations/secrets/inventory/secrets-inventory.txt:7:/Users/wonderland/Wonderland/secrets/.openai_token_vault
/Users/wonderland/Wonderland/vault/07-Operations/secrets/inventory/secrets-inventory.txt:8:/Users/wonderland/Wonderland/secrets/wl-registry.json
/Users/wonderland/Wonderland/vault/07-Operations/secrets/inventory/secrets-inventory.txt:9:/Users/wonderland/Wonderland/secrets/.gemini_token_vault
/Users/wonderland/Wonderland/vault/07-Operations/secrets/inventory/secrets-inventory.txt:10:/Users/wonderland/Wonderland/secrets/.anthropic_token_vault
/Users/wonderland/Wonderland/vault/07-Operations/platform/universe-graph.json:4:  "root": "/Users/wonderland/Wonderland",
/Users/wonderland/Wonderland/vault/07-Operations/platform/platform-registry.json:3:  "authority_root": "/Users/wonderland/Wonderland",
/Users/wonderland/Wonderland/vault/03-Runbooks/authority/authority-backup-restore.runbook.md:10:/Users/wonderland/Wonderland
/Users/wonderland/Wonderland/vault/00-Core/manifests/seed-vault-manifest.md:11:/Users/wonderland/Wonderland/vault/00-Core
/Users/wonderland/Wonderland/vault/00-Core/manifests/vault-state.json:8:  "path": "/Users/wonderland/Wonderland/vault/00-Core"
/Users/wonderland/Wonderland/vault/06-Services/checks/verify-services.sh:5:WONDERLAND="/Users/wonderland/Wonderland"
/Users/wonderland/Wonderland/vault/chaos/watchdog.launchd.out.log:2:Missing manager: /Users/wonderland/Wonderland/ephemeral/ephemeral_manager.py
/Users/wonderland/Wonderland/vault/chaos/watchdog.launchd.out.log:4:Missing manager: /Users/wonderland/Wonderland/ephemeral/ephemeral_manager.py
/Users/wonderland/Wonderland/vault/chaos/watchdog.launchd.out.log:6:Missing manager: /Users/wonderland/Wonderland/ephemeral/ephemeral_manager.py
/Users/wonderland/Wonderland/vault/chaos/watchdog.launchd.out.log:8:Missing manager: /Users/wonderland/Wonderland/ephemeral/ephemeral_manager.py
/Users/wonderland/Wonderland/vault/chaos/watchdog.launchd.out.log:11:Missing manager: /Users/wonderland/Wonderland/ephemeral/ephemeral_manager.py
/Users/wonderland/Wonderland/vault/chaos/watchdog.launchd.out.log:13:Missing manager: /Users/wonderland/Wonderland/ephemeral/ephemeral_manager.py
/Users/wonderland/Wonderland/vault/chaos/panic.log:14:[2026-06-23T09:26:12-07:00] chaos mode active: /Users/wonderland/Wonderland/vault/chaos/chaos-aether.json
/Users/wonderland/Wonderland/vault/chaos/panic.log:16:[2026-06-23T09:30:33-07:00] chaos mode active: /Users/wonderland/Wonderland/vault/chaos/chaos-aether.json
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
PASS loki                     +10
FAIL prometheus               +0
PASS grafana                  +10

Health Score: 60/100
RESULT FAIL

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

REPORT=/Users/wonderland/Wonderland/vault/08-Operations/reports/portability-hardening-20260625-060643.md
BACKUP=/Users/wonderland/Wonderland/.backup/portability-hardening-20260625-060643
