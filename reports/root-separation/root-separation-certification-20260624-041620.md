# Root Separation Certification

Date: 2026-06-24T04:16:20-07:00
WL_HOME=/Users/wonderland/Wonderland

## Checks
PASS bin exists
PASS lib exists
PASS wl-roots.sh exists
PASS root exists: /Users/wonderland/Wonderland
PASS root exists: /Users/wonderland/Workshop
PASS root exists: /Users/wonderland/Runtime
PASS root exists: /Users/wonderland/Archive
PASS root exists: /Users/wonderland/Media
PASS wl command available: /Users/wonderland/Wonderland/bin/wl
PASS wl path works
PASS wl nav works

## Hardcoded Path Audit
FAIL legacy Wonderland-v4 references found
/Users/wonderland/Wonderland/bin/wl-storage.bak.20260618153434:76:    "$VOLUME_PATH/Wonderland-v4" \
/Users/wonderland/Wonderland/bin/wl-root-certify:70:  'Wonderland-v4\|T7_Wonderland/Wonderland-v4\|/Wonderland-v4' \
/Users/wonderland/Wonderland/bin/wl-root-certify:74:  pass "no legacy Wonderland-v4 hardcoded references in authority paths"
/Users/wonderland/Wonderland/bin/wl-root-certify:76:  fail "legacy Wonderland-v4 references found"
/Users/wonderland/Wonderland/bin/wl.bak-rootless-runtime-20260623-180724:212:        "$WL_HOME/Wonderland-v4/docker-compose.yml" || true)"
/Users/wonderland/Wonderland/bin/wl.bak-rootless-runtime-20260623-180724:290:      local snap2="/Volumes/T7_Wonderland/Wonderland-v4/08-operations/snapshots"
/Users/wonderland/Wonderland/bin/wl.backup.20260621-184044:257:      local snap2="/Volumes/T7_Wonderland/Wonderland-v4/08-operations/snapshots"
/Users/wonderland/Wonderland/bin/wl.bak-services-runtime-boundary:212:        "$WL_HOME/Wonderland-v4/docker-compose.yml" || true)"
/Users/wonderland/Wonderland/bin/wl.bak-services-runtime-boundary:290:      local snap2="/Volumes/T7_Wonderland/Wonderland-v4/08-operations/snapshots"
/Users/wonderland/Wonderland/bin/wl-shell-repair:28:# --- Wonderland-v4 Structural Path Strategy ---
/Users/wonderland/Wonderland/bin/wl-path-fix:26:# --- Wonderland-v4 Structural Path Strategy ---
/Users/wonderland/Wonderland/bin/wl.bak-runtime-services-20260623-181147:212:        "$WL_HOME/Wonderland-v4/docker-compose.yml" || true)"
/Users/wonderland/Wonderland/bin/wl.bak-runtime-services-20260623-181147:290:      local snap2="/Volumes/T7_Wonderland/Wonderland-v4/08-operations/snapshots"
/Users/wonderland/Wonderland/bin/wl:336:      local snap2="/Volumes/T7_Wonderland/Wonderland-v4/08-operations/snapshots"
/Users/wonderland/Wonderland/bin/wl-storage.bak.20260618154006:76:    "$VOLUME_PATH/Wonderland-v4" \
/Users/wonderland/Wonderland/bin/wl-context:6:ROOT_V4="${WONDERLAND_ROOT_V4:-$HOME/Wonderland-v4}"
/Users/wonderland/Wonderland/bin/wl-ga-plus-install:27:echo "Wonderland-v4 GA+ installed."
/Users/wonderland/Wonderland/bin/wl-mind-body:20:Mind + Body Time Travel for Wonderland-v4.
/Users/wonderland/Wonderland/bin/wl.bak.20260623-193136:311:      local snap2="/Volumes/T7_Wonderland/Wonderland-v4/08-operations/snapshots"
/Users/wonderland/Wonderland/bin/wl.broken-minimal-20260621:71:  if [[ -x "$WL_HOME/Wonderland-v4/ephemeral/bin/wl-ephemeral" ]]; then
/Users/wonderland/Wonderland/bin/wl.broken-minimal-20260621:123:    if [[ -x "$WL_HOME/Wonderland-v4/ephemeral/bin/wl-ephemeral" ]]; then
/Users/wonderland/Wonderland/bin/wl.broken-minimal-20260621:124:      exec "$WL_HOME/Wonderland-v4/ephemeral/bin/wl-ephemeral" "$@"
/Users/wonderland/Wonderland/bin/wl.broken-minimal-20260621:126:    echo "FAIL missing executable: $WL_HOME/Wonderland-v4/ephemeral/bin/wl-ephemeral"
/Users/wonderland/Wonderland/bin/wl.bak.20260606-083617:20:  echo "Wonderland-v4 GA+"
/Users/wonderland/Wonderland/bin/wl.bak.20260606-083617:50:  echo "Wonderland-v4 GA+ Doctor"
/Users/wonderland/Wonderland/bin/wl.bak.20260606-083617:183:Wonderland-v4 GA+
/Users/wonderland/Wonderland/bin/wl.bak.20260622-130616:270:      local snap2="/Volumes/T7_Wonderland/Wonderland-v4/08-operations/snapshots"
/Users/wonderland/Wonderland/bin/wl.bak.20260622-130810:270:      local snap2="/Volumes/T7_Wonderland/Wonderland-v4/08-operations/snapshots"
/Users/wonderland/Wonderland/bin/wl-storage:76:    "$VOLUME_PATH/Wonderland-v4" \
/Users/wonderland/Wonderland/bin/wl.bak-runtime-services-20260623-181142:212:        "$WL_HOME/Wonderland-v4/docker-compose.yml" || true)"
/Users/wonderland/Wonderland/bin/wl.bak-runtime-services-20260623-181142:290:      local snap2="/Volumes/T7_Wonderland/Wonderland-v4/08-operations/snapshots"
/Users/wonderland/Wonderland/bin/wl-legacy-promote:5:LEGACY="/Volumes/T7_Wonderland/Wonderland-v4"
/Users/wonderland/Wonderland/bin/wl.bak-runtime-up-down-exec:212:        "$WL_HOME/Wonderland-v4/docker-compose.yml" || true)"
/Users/wonderland/Wonderland/bin/wl.bak-runtime-up-down-exec:290:      local snap2="/Volumes/T7_Wonderland/Wonderland-v4/08-operations/snapshots"
/Users/wonderland/Wonderland/bin/wl-storage.bak.20260618153643:76:    "$VOLUME_PATH/Wonderland-v4" \
/Users/wonderland/Wonderland/bin/wl-legacy:5:LEGACY="/Volumes/T7_Wonderland/Wonderland-v4"
/Users/wonderland/Wonderland/bin/wl-legacy:135:    DEST="$ARCHIVE/Wonderland-v4-archive-$STAMP"
/Users/wonderland/Wonderland/vault/08-Operations/snapshots/snapshot-20260621-065245/manifest.txt:36108: M Wonderland-v4
/Users/wonderland/Wonderland/vault/08-Operations/snapshots/snapshot-20260623-160243/manifest.txt:22: m Wonderland-v4
/Users/wonderland/Wonderland/vault/08-Operations/snapshots/snapshot-20260623-152927/manifest.txt:22: m Wonderland-v4
/Users/wonderland/Wonderland/vault/08-Operations/snapshots/snapshot-20260623-153020/manifest.txt:22: m Wonderland-v4
/Users/wonderland/Wonderland/vault/08-Operations/snapshots/snapshot-20260623-160234/manifest.txt:22: m Wonderland-v4
/Users/wonderland/Wonderland/vault/08-Operations/snapshots/snapshot-20260623-160725/manifest.txt:22: m Wonderland-v4
/Users/wonderland/Wonderland/vault/08-Operations/snapshots/snapshot-20260623-153455/manifest.txt:22: m Wonderland-v4
/Users/wonderland/Wonderland/vault/08-Operations/snapshots/snapshot-20260623-180802/manifest.txt:22: D Wonderland-v4
/Users/wonderland/Wonderland/vault/08-Operations/snapshots/snapshot-20260623-172925/manifest.txt:22: m Wonderland-v4
/Users/wonderland/Wonderland/vault/08-Operations/snapshots/snapshot-20260623-152952/manifest.txt:22: m Wonderland-v4
/Users/wonderland/Wonderland/vault/08-Operations/snapshots/snapshot-20260623-180557/manifest.txt:22: D Wonderland-v4
/Users/wonderland/Wonderland/vault/08-Operations/snapshots/snapshot-20260623-154720/manifest.txt:22: m Wonderland-v4
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch.bak.20260623-122301:4374:+let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch.bak.20260623-122301:4774:+        let output = shell("python3 \(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch.bak.20260623-122301:4821:+let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch.bak.20260623-122301:4987:+        let output = shell("python3 \(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch.bak.20260623-122301:5050:+let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch.bak.20260623-122301:5216:+        let output = shell("python3 \(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch.bak.20260623-122301:5279:+let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch.bak.20260623-122301:5487:+        let output = shell("python3 \(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch.bak.20260623-122301:5550:+let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch.bak.20260623-122301:5790:+        let output = shell("python3 \(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch.bak.20260623-122301:5853:+let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch.bak.20260623-122301:6127:+        let output = shell("python3 \(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch.bak.20260623-122301:6190:+let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch.bak.20260623-122301:6590:+        let output = shell("python3 \(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch.bak.20260623-122301:6654:+let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch.bak.20260623-122301:7074:+        let output = shell("python3 \(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch.bak.20260623-122301:7137:+let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch.bak.20260623-122301:7537:+        let output = shell("python3 \(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch.bak.20260623-122301:7657:+let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch.bak.20260623-122301:8057:+        let output = shell("python3 \(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch:4374:+let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch:4774:+        let output = shell("python3 \(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch:4821:+let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch:4987:+        let output = shell("python3 \(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch:5050:+let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch:5216:+        let output = shell("python3 \(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch:5279:+let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch:5487:+        let output = shell("python3 \(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch:5550:+let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch:5790:+        let output = shell("python3 \(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch:5853:+let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch:6127:+        let output = shell("python3 \(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch:6190:+let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch:6590:+        let output = shell("python3 \(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch:6654:+let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch:7074:+        let output = shell("python3 \(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch:7137:+let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch:7537:+        let output = shell("python3 \(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch:7657:+let chaosBin = wlRoot + "/Wonderland-v4/ephemeral/bin"
/Users/wonderland/Wonderland/vault/08-Operations/recovery/git-rescue/chaos-menubar-staged-20260621-183208.patch:8057:+        let output = shell("python3 \(wlRoot)/Wonderland-v4/governance/verify-chaos.py")
/Users/wonderland/Wonderland/vault/08-Operations/backups/bin-wl/20260621-063835/wl.backup:178:      elif [[ -x "$WL_HOME/Wonderland-v4/ephemeral/bin/wl-ephemeral" ]]; then
/Users/wonderland/Wonderland/vault/08-Operations/backups/bin-wl/20260621-063835/wl.backup:179:        exec "$WL_HOME/Wonderland-v4/ephemeral/bin/wl-ephemeral" "$@"
/Users/wonderland/Wonderland/vault/09-Governance/legacy/import-quarantine-policy.md:5:Prevent unsafe legacy artifacts from being promoted into Wonderland-v4 active domains.
/Users/wonderland/Wonderland/vault/09-Governance/mahaney/mahaney-core.md:4:System: Wonderland-v4  
/Users/wonderland/Wonderland/vault/09-Governance/standards/wl-gov-006-legacy-import-archive-standard.md:16:/Volumes/T7_Wonderland/Wonderland-v4
/Users/wonderland/Wonderland/vault/chat-architecture/20260623-083655/chat-architecture-map.md:138:- **Infrastructure:** Apple Silicon (M4 MacBook Air), rootless nerdctl/containerd (no Docker Desktop), ~/Wonderland/vault (authoritative, wins conflicts), ~/Wonderland/Wonderland-v4 (impl workspace).
/Users/wonderland/Wonderland/vault/07-Operations/platform/storage-authority.json:7:    "Wonderland-v4",
/Users/wonderland/Wonderland/vault/07-Operations/state/state-20260609-150322.json:26:    "?? Wonderland-v4/",
/Users/wonderland/Wonderland/vault/07-Operations/drift/drift-20260609-150021.json:25:      "?? Wonderland-v4/",
/Users/wonderland/Wonderland/vault/07-Operations/drift/drift-20260609-140742.json:23:      "?? Wonderland-v4/",
/Users/wonderland/Wonderland/vault/07-Operations/legacy-import/promoted/timetravel-recovery-manifest.md:7:Wonderland-v4
/Users/wonderland/Wonderland/vault/07-Operations/legacy-import/promoted/legacy-readme.md:1:# Wonderland-v4
/Users/wonderland/Wonderland/vault/07-Operations/legacy-import/promoted/legacy-readme.md:3:Wonderland-v4 is a modular digital ecosystem operated by Matthew Mahaney.
/Users/wonderland/Wonderland/vault/07-Operations/legacy-import/promoted/restore-wl-20260528.md:13:Primary Wonderland-v3 recovery snapshot imported into Wonderland-v4 archive.
/Users/wonderland/Wonderland/vault/07-Operations/legacy-import/promoted/architect-charter.md:5:Architect is the external design, governance, documentation, and systems-engineering layer for Wonderland-v4.
/Users/wonderland/Wonderland/vault/07-Operations/legacy-import/promoted/architect-charter.md:41:Architect must not become a runtime dependency for Wonderland-v4.
/Users/wonderland/Wonderland/vault/07-Operations/legacy-import/promoted/legacy-wonderland-registry.yaml:1:system: Wonderland-v4
/Users/wonderland/Wonderland/vault/07-Operations/legacy-import/promoted/recovered-v3-runtime-index.md:26:This index captures the recovered Wonderland-v3 runtime model for use in Wonderland-v4 architecture planning.
/Users/wonderland/Wonderland/vault/07-Operations/legacy-import/promoted/wonderland-v4-overview.md:1:# Wonderland-v4 Overview
/Users/wonderland/Wonderland/vault/07-Operations/legacy-import/promoted/wonderland-v4-overview.md:5:Wonderland-v4 is a modular ecosystem for infrastructure, automation, software development, knowledge management, creative systems, and operational governance.
/Users/wonderland/Wonderland/vault/07-Operations/legacy-import/promoted/wonderland-v4-overview.md:33:Wonderland-v4 should remain:
/Users/wonderland/Wonderland/vault/07-Operations/legacy-import/promoted/architect-memory-index.md:9:Wonderland-v4
/Users/wonderland/Wonderland/vault/07-Operations/legacy-import/promoted/recovery-catalog.md:38:Recovered into Wonderland-v4.
/Users/wonderland/Wonderland/vault/07-Operations/legacy-import/promoted/wonderland-v3-to-v4-migration-model.md:1:# Wonderland-v3 to Wonderland-v4 Migration Model
/Users/wonderland/Wonderland/vault/07-Operations/legacy-import/promoted/wonderland-v3-to-v4-migration-model.md:81:Wonderland-v4 may reuse Wonderland-v3 knowledge.
/Users/wonderland/Wonderland/vault/07-Operations/legacy-import/promoted/wonderland-v3-to-v4-migration-model.md:83:Wonderland-v4 must not inherit Wonderland-v3 runtime fragility.
/Users/wonderland/Wonderland/vault/07-Operations/legacy-import/promoted/wonderland-v4-roadmap.md:1:# Wonderland-v4 Roadmap
/Users/wonderland/Wonderland/vault/ephemeral-secret-agent-catalog/20260623-060816/DROP_NOTICE.txt:2:Source: Wonderland-v4/ephemeral-agents/secret-agent-catalog/
/Users/wonderland/Wonderland/vault/ephemeral-secret-agent-catalog/20260623-060732/DROP_NOTICE.txt:2:Source: Wonderland-v4/ephemeral-agents/secret-agent-catalog/
/Users/wonderland/Wonderland/vault/ephemeral-secret-agent-catalog/20260623-061236/DROP_NOTICE.txt:2:Source: Wonderland-v4/ephemeral-agents/secret-agent-catalog/
/Users/wonderland/Wonderland/vault/00-Core/topology/root-map.md:7:/Volumes/T7_Wonderland/Wonderland-v4
/Users/wonderland/Wonderland/vault/06-Services/docs/legacy-infrastructure-architecture.md:5:Provide persistent, recoverable, auditable infrastructure for Wonderland-v4.
/Users/wonderland/Wonderland/vault/06-Services/docs/legacy-docker-readme.md:1:# Wonderland-v4 Docker Runtime Candidates
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:1:/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar: line 1: import: command not found
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:3:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:7:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:11:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:15:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:19:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:23:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:27:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:31:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:34:/opt/homebrew/Cellar/python@3.14/3.14.6/Frameworks/Python.framework/Versions/3.14/Resources/Python.app/Contents/MacOS/Python: can't open file '/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py': [Errno 2] No such file or directory
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:36:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:40:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:44:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:48:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:52:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:56:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:60:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:64:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:68:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:72:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:76:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:80:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:84:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:88:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:92:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:96:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:100:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:104:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:108:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:112:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:116:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:120:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:124:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:128:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:132:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:136:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:140:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:144:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:148:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:152:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:156:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:160:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:164:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:168:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:172:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:176:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:180:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:184:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/chaos/menubar.launchd.err.log:188:  File "/Users/wonderland/Wonderland/Wonderland-v4/ephemeral/bin/wl-chaos-menubar.py", line 6, in <module>
/Users/wonderland/Wonderland/vault/backups/skhd/skhdrc-20260621-151711.backup:2:cmd + ctrl + alt + shift - p : export PATH="$HOME/Wonderland/Wonderland-v4/ephemeral/bin:$PATH"; wl-chaos-panic --force "Global hotkey panic triggered"
/Users/wonderland/Wonderland/vault/backups/skhd/skhdrc-20260621-151711.backup:9:cmd + ctrl + alt + shift - o : export PATH="$HOME/Wonderland/Wonderland-v4/ephemeral/bin:$PATH"; wl chaos reset; wl visual-chaos write-contract; wl visual-chaos launch-all
/Users/wonderland/Wonderland/vault/backups/skhd/skhdrc-20260621-151711.backup:13:cmd + ctrl + alt + shift - i : export PATH="$HOME/Wonderland/Wonderland-v4/ephemeral/bin:$PATH"; wl chaos checkin
/Users/wonderland/Wonderland/vault/backups/skhd/skhdrc-20260621-151711.backup:17:cmd + ctrl + alt + shift - t : export PATH="$HOME/Wonderland/Wonderland-v4/ephemeral/bin:$PATH"; wl chaos countdown

RESULT FAIL
