#!/usr/bin/env bash
set -euo pipefail

wl_arch_root() {
  printf '%s\n' "${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
}

wl_arch_report() {
  local root out
  root="$(wl_arch_root)"
  out="$root/vault/05-Registry/architecture/report.txt"
  mkdir -p "$(dirname "$out")"

  {
    echo "Wonderland Architecture Report"
    echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo
    echo "Module counts"
    echo "-------------"
    find "$root/lib" -type f -name '*.sh' 2>/dev/null \
      | sed "s#^$root/lib/##" \
      | awk -F/ '{print $1}' \
      | sort | uniq -c | sort -nr
    echo
    echo "Largest modules"
    echo "---------------"
    find "$root/lib" -type f -name '*.sh' 2>/dev/null \
      | while read -r f; do wc -l "$f"; done \
      | sort -nr | head -20 \
      | sed "s#$root/##"
    echo
    echo "Command inventory"
    echo "-----------------"
    echo "bin commands: $(find "$root/bin" -maxdepth 1 -type f -perm -111 2>/dev/null | wc -l | tr -d ' ')"
    echo "bootstrap wrappers: $(grep -RIl 'lib/wl-bootstrap.sh' "$root/bin" 2>/dev/null | wc -l | tr -d ' ')"
    echo "feature-like commands: $(find "$root/bin" -maxdepth 1 -type f -perm -111 2>/dev/null | while read -r f; do [[ "$(wc -l < "$f" | tr -d ' ')" -gt 25 ]] && echo "$f"; done | wc -l | tr -d ' ')"
    echo
    echo "Applications"
    echo "------------"
    find "$root/apps" "$root/Workshop/apps" -maxdepth 3 -type d 2>/dev/null | sed "s#$root/##" | sort | head -100 || true
  } > "$out"

  cat "$out"
  echo
  echo "PASS architecture report $out"
}

wl_arch_graph() {
  local root out
  root="$(wl_arch_root)"
  out="$root/vault/05-Registry/architecture/dependency.dot"
  mkdir -p "$(dirname "$out")"

  {
    echo "digraph WonderlandShellDependencies {"
    echo '  rankdir=LR;'
    find "$root/lib" -type f -name '*.sh' 2>/dev/null | while read -r f; do
      local from
      from="$(basename "$f")"
      grep -E '(^|[[:space:]])(\.|source)[[:space:]]+["'\'']?\$?ROOT/' "$f" 2>/dev/null \
        | sed -E 's/.*(lib\/[^"'\'' ]+\.sh).*/\1/' \
        | while read -r dep; do
            [[ "$dep" == lib/* ]] || continue
            printf '  "%s" -> "%s";\n' "$from" "$(basename "$dep")"
          done
    done
    echo "}"
  } > "$out"

  echo "PASS architecture graph $out"
}


wl_arch_snapshot() {
  local root out latest
  root="$(wl_arch_root)"
  out="$root/vault/05-Registry/architecture/baselines/architecture-$(
    date -u +%Y%m%d-%H%M%S
  ).tsv"
  latest="$root/vault/05-Registry/architecture/baselines/latest.tsv"
  mkdir -p "$(dirname "$out")"

  {
    printf 'metric\tvalue\n'
    printf 'lib_modules\t%s\n' "$(find "$root/lib" -type f -name '*.sh' 2>/dev/null | wc -l | tr -d ' ')"
    printf 'bin_commands\t%s\n' "$(find "$root/bin" -maxdepth 1 -type f -perm -111 2>/dev/null | wc -l | tr -d ' ')"
    printf 'bootstrap_wrappers\t%s\n' "$(grep -RIl 'lib/wl-bootstrap.sh' "$root/bin" 2>/dev/null | wc -l | tr -d ' ')"
    printf 'oversized_modules_gt_250\t%s\n' "$(find "$root/lib" -type f -name '*.sh' 2>/dev/null | while read -r f; do [[ "$(wc -l < "$f" | tr -d ' ')" -gt 250 ]] && echo "$f"; done | wc -l | tr -d ' ')"
    printf 'doctor_modules\t%s\n' "$(find "$root/lib/doctor" -type f -name '*.sh' 2>/dev/null | wc -l | tr -d ' ')"
    printf 'engineering_modules\t%s\n' "$(find "$root/lib/architecture" "$root/lib/inventory" "$root/lib/lint" "$root/lib/migrate" "$root/lib/refactor" "$root/lib/fix" "$root/lib/gate" "$root/lib/report" -type f -name '*.sh' 2>/dev/null | wc -l | tr -d ' ')"
  } > "$out"

  cp "$out" "$latest"
  cat "$out"
  echo
  echo "PASS architecture snapshot $out"
}

wl_arch_score() {
  local root modules oversized doctor engineering score
  root="$(wl_arch_root)"

  modules="$(find "$root/lib" -type f -name '*.sh' 2>/dev/null | wc -l | tr -d ' ')"
  oversized="$(find "$root/lib" -type f -name '*.sh' 2>/dev/null | while read -r f; do [[ "$(wc -l < "$f" | tr -d ' ')" -gt 250 ]] && echo "$f"; done | wc -l | tr -d ' ')"
  doctor="$(find "$root/lib/doctor" -type f -name '*.sh' 2>/dev/null | wc -l | tr -d ' ')"
  engineering="$(find "$root/lib/architecture" "$root/lib/inventory" "$root/lib/lint" "$root/lib/migrate" "$root/lib/refactor" "$root/lib/fix" "$root/lib/gate" "$root/lib/report" -type f -name '*.sh' 2>/dev/null | wc -l | tr -d ' ')"

  score=100
  score=$(( score - oversized * 10 ))
  [[ "$doctor" -lt 8 ]] && score=$(( score - 10 ))
  [[ "$engineering" -lt 6 ]] && score=$(( score - 10 ))
  [[ "$modules" -lt 10 ]] && score=$(( score - 5 ))
  [[ "$score" -lt 0 ]] && score=0

  echo "Wonderland Architecture Score"
  echo "score=$score"
  echo "modules=$modules"
  echo "oversized_modules_gt_250=$oversized"
  echo "doctor_modules=$doctor"
  echo "engineering_modules=$engineering"

  if [[ "$score" -ge 90 ]]; then
    echo "RESULT PASS"
  elif [[ "$score" -ge 75 ]]; then
    echo "RESULT WARN"
  else
    echo "RESULT FAIL"
    return 1
  fi
}

wl_arch_drift() {
  local root latest current tmp failed=0
  root="$(wl_arch_root)"
  latest="$root/vault/05-Registry/architecture/baselines/latest.tsv"
  tmp="$(mktemp)"

  if [[ ! -f "$latest" ]]; then
    echo "WARN no architecture baseline exists"
    echo "Run: wl architecture snapshot"
    return 0
  fi

  WL_ROOT="$root" wl_arch_snapshot > /dev/null
  current="$latest"

  echo "Wonderland Architecture Drift"
  echo "Baseline: $latest"
  echo

  cp "$current" "$tmp"

  awk -F '\t' '
    NR==FNR && NR>1 { base[$1]=$2; next }
    NR>1 {
      old=base[$1]
      new=$2
      if (old != "" && old != new) {
        printf "DRIFT %s %s -> %s\n", $1, old, new
      }
    }
  ' "$latest" "$tmp" || failed=1

  rm -f "$tmp"

  echo "RESULT PASS"
  return "$failed"
}


wl_arch_functions() {
  local root out
  root="$(wl_arch_root)"
  out="$root/vault/05-Registry/architecture/dependencies/functions.tsv"
  mkdir -p "$(dirname "$out")"

  {
    printf 'function\tfile\n'
    find "$root/lib" -type f -name '*.sh' 2>/dev/null | sort | while read -r f; do
      grep -E '^[a-zA-Z_][a-zA-Z0-9_]+[[:space:]]*\(\)[[:space:]]*\{' "$f" 2>/dev/null \
        | sed -E 's/[[:space:]]*\(\)[[:space:]]*\{//' \
        | while read -r fn; do
            printf '%s\t%s\n' "$fn" "${f#$root/}"
          done
    done
  } > "$out"

  column -t -s $'\t' "$out"
  echo
  echo "PASS functions inventory $out"
}

wl_arch_imports() {
  local root out
  root="$(wl_arch_root)"
  out="$root/vault/05-Registry/architecture/dependencies/imports.tsv"
  mkdir -p "$(dirname "$out")"

  {
    printf 'from\tto\n'
    find "$root/lib" -type f -name '*.sh' 2>/dev/null | sort | while read -r f; do
      rel="${f#$root/}"
      grep -E '(^|[[:space:]])(\.|source)[[:space:]]+' "$f" 2>/dev/null \
        | grep -E 'lib/.*\.sh' \
        | sed -E 's/.*(lib\/[^"'\'' ]+\.sh).*/\1/' \
        | while read -r dep; do
            printf '%s\t%s\n' "$rel" "$dep"
          done
    done
  } > "$out"

  column -t -s $'\t' "$out"
  echo
  echo "PASS imports inventory $out"
}

wl_arch_duplicates() {
  local root out dup failed=0
  root="$(wl_arch_root)"
  out="$root/vault/05-Registry/architecture/dependencies/duplicate-functions.txt"
  mkdir -p "$(dirname "$out")"

  wl_arch_functions >/dev/null

  awk -F '\t' 'NR>1 { count[$1]++; files[$1]=files[$1] " " $2 } END { for (f in count) if (count[f] > 1) print f, files[f] }' \
    "$root/vault/05-Registry/architecture/dependencies/functions.tsv" \
    | sort > "$out"

  if [[ -s "$out" ]]; then
    cat "$out"
    echo "RESULT WARN"
  else
    echo "PASS no duplicate shell functions"
    echo "RESULT PASS"
  fi
}

wl_arch_cycles() {
  local root imports out
  root="$(wl_arch_root)"
  imports="$root/vault/05-Registry/architecture/dependencies/imports.tsv"
  out="$root/vault/05-Registry/architecture/dependencies/cycle-check.txt"
  mkdir -p "$(dirname "$out")"

  wl_arch_imports >/dev/null

  python3 - "$imports" "$out" <<'PY2'
import sys
from collections import defaultdict

imports, out = sys.argv[1], sys.argv[2]
graph = defaultdict(list)

with open(imports) as f:
    next(f, None)
    for line in f:
        line = line.rstrip("\n")
        if not line:
            continue
        src, dst = line.split("\t", 1)
        graph[src].append(dst)

visiting = set()
visited = set()
cycles = []

def dfs(node, path):
    if node in visiting:
        i = path.index(node) if node in path else 0
        cycles.append(path[i:] + [node])
        return
    if node in visited:
        return
    visiting.add(node)
    for nxt in graph.get(node, []):
        dfs(nxt, path + [nxt])
    visiting.remove(node)
    visited.add(node)

for node in list(graph):
    dfs(node, [node])

with open(out, "w") as f:
    if cycles:
        for c in cycles:
            f.write("CYCLE " + " -> ".join(c) + "\n")
    else:
        f.write("PASS no import cycles detected\n")
PY2

  cat "$out"
  if grep -q '^CYCLE ' "$out"; then
    echo "RESULT FAIL"
    return 1
  fi
  echo "RESULT PASS"
}

wl_arch_usage() {
  cat <<'TXT'
Usage:
  wl architecture report
  wl architecture graph
TXT
}

wl_architecture_main() {
  case "${1:-report}" in
    report) wl_arch_report ;;
    graph) wl_arch_graph ;;
    snapshot) wl_arch_snapshot ;;
    score) wl_arch_score ;;
    drift) wl_arch_drift ;;
    functions) wl_arch_functions ;;
    imports) wl_arch_imports ;;
    duplicates) wl_arch_duplicates ;;
    cycles) wl_arch_cycles ;;
    -h|--help|help) wl_arch_usage ;;
    *) wl_arch_usage; return 2 ;;
  esac
}
