#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
APPS="$ROOT/apps/tauri"
SHARED="$ROOT/shared/wonderland-chaos"
REPORT="$ROOT/vault/08-Operations/reports/native-chaos-reader-drop-in-report.txt"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$SHARED" "$(dirname "$REPORT")"

cat > "$SHARED/ChaosContract.swift" <<'SWIFT'
import Foundation

struct ChaosContract: Codable {
    struct AppConfig: Codable {
        let enabled: Bool?

        let rings: Int?
        let rotation_speed: Double?
        let easing: String?
        let jitter: Double?

        let intensity: Double?
        let mode: String?
        let trail_decay: String?

        let particles: Int?
        let living_ratio: Double?
        let waste_decay: String?
        let slam_force: Double?
    }

    let version: String
    let updated_at: String
    let chaos_active: Bool
    let apps: [String: AppConfig]
}
SWIFT

cat > "$SHARED/ChaosLoader.swift" <<'SWIFT'
import Foundation

enum ChaosLoader {
    static let defaultPath =
        "\(NSHomeDirectory())/Wonderland/vault/chaos/visual-chaos-contract.json"

    static func load() -> ChaosContract? {
        let env = ProcessInfo.processInfo.environment["WL_CHAOS_CONTRACT"]
        let path = env ?? defaultPath

        guard
            FileManager.default.fileExists(atPath: path),
            let data = FileManager.default.contents(atPath: path)
        else {
            return nil
        }

        return try? JSONDecoder().decode(ChaosContract.self, from: data)
    }
}
SWIFT

cat > "$SHARED/ChaosEnvironment.swift" <<'SWIFT'
import Foundation
import Combine
import AppKit

final class ChaosEnvironment: ObservableObject {
    @Published var contract: ChaosContract?

    private var timer: Timer?

    init() {
        reload()

        timer = Timer.scheduledTimer(
            withTimeInterval: 30,
            repeats: true
        ) { [weak self] _ in
            self?.reload()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadNotification),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(reloadNotification),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }

    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    @objc
    private func reloadNotification() {
        reload()
    }

    func reload() {
        contract = ChaosLoader.load()
    }

    func config(for appName: String) -> ChaosContract.AppConfig? {
        contract?.apps[appName]
    }
}
SWIFT

: > "$REPORT"

log() {
  echo "$*" | tee -a "$REPORT"
}

copy_shared_into_app() {
  local app="$1"
  local target="$APPS/$app/src-tauri/Sources/WonderlandChaos"

  if [[ -d "$APPS/$app/src-tauri/Sources" ]]; then
    mkdir -p "$target"
    cp "$SHARED/"*.swift "$target/"
    log "PASS copied shared chaos Swift files into $target"
  else
    log "WARN no Swift Sources dir found for $app"
  fi
}

patch_file() {
  local file="$1"
  local app="$2"

  [[ -f "$file" ]] || return 0
  cp "$file" "$file.backup.$STAMP"

  python3 - "$file" "$app" <<'PY'
from pathlib import Path
import sys, re

path = Path(sys.argv[1])
app = sys.argv[2]
s = path.read_text()
orig = s

if "ChaosEnvironment" not in s:
    # Insert a simple owned environment near common class/struct bodies if possible.
    s = re.sub(
        r'(final\s+class\s+\w+ViewModel[^{]*\{)',
        r'\1\n    @ObservedObject var chaos = ChaosEnvironment()\n',
        s,
        count=1,
    )
    s = re.sub(
        r'(class\s+\w+ViewModel[^{]*\{)',
        r'\1\n    @ObservedObject var chaos = ChaosEnvironment()\n',
        s,
        count=1,
    )

if app == "wl-spin-city":
    s = s.replace(
        "ringCount = 3",
        '''if let cfg = chaos.contract?.apps["wl-spin-city"] {
            ringCount = cfg.rings ?? 3
            rotationSpeed = cfg.rotation_speed ?? 1.0
            jitter = cfg.jitter ?? 0.35
        } else {
            ringCount = 3
        }'''
    )
    s = s.replace(
        "rotationSpeed = 1.0",
        '''if chaos.contract?.apps["wl-spin-city"] == nil {
            rotationSpeed = 1.0
        }'''
    )

if app == "wl-agitate":
    s = s.replace(
        "agitationIntensity = 0.6",
        '''if let cfg = chaos.contract?.apps["wl-agitate"] {
            agitationIntensity = cfg.intensity ?? 0.6
        } else {
            agitationIntensity = 0.6
        }'''
    )

if app == "wl-matrix":
    s = s.replace(
        "particleCount = 1200",
        '''if let cfg = chaos.contract?.apps["wl-matrix"] {
            particleCount = cfg.particles ?? 1200
            livingRatio = cfg.living_ratio ?? 0.35
        } else {
            particleCount = 1200
        }'''
    )
    s = s.replace(
        "livingRatio = 0.35",
        '''if chaos.contract?.apps["wl-matrix"] == nil {
            livingRatio = 0.35
        }'''
    )

if s != orig:
    path.write_text(s)
    print("PATCHED")
else:
    print("UNCHANGED")
PY
}

patch_app_sources() {
  local app="$1"
  local dir="$APPS/$app"

  if [[ ! -d "$dir" ]]; then
    log "WARN missing app dir: $dir"
    return 0
  fi

  copy_shared_into_app "$app"

  local patched=0

  while IFS= read -r file; do
    case "$app" in
      wl-spin-city)
        if grep -q "ringCount = 3\|rotationSpeed = 1.0\|SpinCityViewModel" "$file"; then
          result="$(patch_file "$file" "$app")"
          log "$result $file"
          [[ "$result" == PATCHED ]] && patched=$((patched + 1))
        fi
        ;;
      wl-agitate)
        if grep -q "agitationIntensity = 0.6" "$file"; then
          result="$(patch_file "$file" "$app")"
          log "$result $file"
          [[ "$result" == PATCHED ]] && patched=$((patched + 1))
        fi
        ;;
      wl-matrix)
        if grep -q "particleCount = 1200\|livingRatio = 0.35" "$file"; then
          result="$(patch_file "$file" "$app")"
          log "$result $file"
          [[ "$result" == PATCHED ]] && patched=$((patched + 1))
        fi
        ;;
    esac
  done < <(find "$dir" -type f -name "*.swift" 2>/dev/null)

  log "SUMMARY $app patched_files=$patched"
}

log "=== Native Chaos Reader Auto Drop-In $STAMP ==="
patch_app_sources "wl-spin-city"
patch_app_sources "wl-agitate"
patch_app_sources "wl-matrix"

log ""
log "Report: $REPORT"
log "Backups: *.backup.$STAMP beside changed Swift files"
