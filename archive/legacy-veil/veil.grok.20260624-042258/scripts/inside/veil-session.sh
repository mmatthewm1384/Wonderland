#!/bin/bash
set -euo pipefail

WORK_DIR="/work/veil"
VAULT_FILE="/vault/veil.age"
TMP_ENCRYPTED="/tmp/veil.new.age"
SEALED=0

do_seal() {
  [ "${SEALED}" -eq 1 ] && return 0
  echo ""
  echo "Sealing vault..."
  if (cd "${WORK_DIR}" && tar --owner=0 --group=0 --mtime="@0" --sort=name -czf - .) | age -p -o "${TMP_ENCRYPTED}"; then
    [ -f "${TMP_ENCRYPTED}" ] && [ -s "${TMP_ENCRYPTED}" ] && mv -f "${TMP_ENCRYPTED}" "${VAULT_FILE}"
    echo "Vault sealed."
  else
    echo "WARNING: Re-encryption aborted."
  fi
  rm -f "${TMP_ENCRYPTED}" 2>/dev/null || true
  SEALED=1
}

cleanup() { do_seal; }
trap cleanup EXIT INT TERM

mkdir -p "${WORK_DIR}"
if [ -f "${VAULT_FILE}" ]; then
  echo "Decrypting vault..."
  age -d "${VAULT_FILE}" | tar xzf - -C "${WORK_DIR}" || { echo "ERROR: Decrypt failed."; exit 1; }
  echo "Unlocked."
else
  echo "Fresh session."
fi

export HISTFILE=/dev/null HISTSIZE=0 HISTFILESIZE=0

show_menu() {
  echo ""
  echo "=== VEIL // SECRET ANONYMOUS DOCUMENTATION ==="
  echo "l) List n) New e) Edit v) View d) Delete s) Seal x) Discard"
  printf "Choice: "
}

while true; do
  show_menu
  read -r choice
  case "${choice}" in
    l|L) find "${WORK_DIR}" -type f | sort | sed "s|^${WORK_DIR}/||";;
    n|N) printf "Path: "; read -r p; [[ "$p" =~ \.\.|^/ ]] && { echo "Invalid"; continue; }; mkdir -p "$(dirname "${WORK_DIR}/$p")"; [ ! -f "${WORK_DIR}/$p" ] && printf "# %s\n\n" "$(basename "$p")" > "${WORK_DIR}/$p"; nano "${WORK_DIR}/$p" || true;;
    e|E) printf "Edit: "; read -r p; f="${WORK_DIR}/$p"; [ -f "$f" ] && [[ ! "$p" =~ \.\.|^/ ]] && nano "$f" || echo "Not found";;
    v|V) printf "View: "; read -r p; f="${WORK_DIR}/$p"; [ -f "$f" ] && [[ ! "$p" =~ \.\.|^/ ]] && less -S "$f" || echo "Not found";;
    d|D) printf "Delete: "; read -r p; f="${WORK_DIR}/$p"; [ -f "$f" ] && [[ ! "$p" =~ \.\.|^/ ]] && rm -i "$f" || echo "Not found";;
    s|S) do_seal; exit 0;;
    x|X) echo "Discarded."; SEALED=1; exit 0;;
    *) echo "Invalid";;
  esac
done
