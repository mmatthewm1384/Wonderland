#!/usr/bin/env bash
set -euo pipefail

echo "== running apps =="
ps aux | grep -Ei 'clip|clipboard|paste|menu|bar|menubar' | grep -v grep || true

echo
echo "== launch agents =="
find "$HOME/Library/LaunchAgents" /Library/LaunchAgents /Library/LaunchDaemons \
  -iname "*.plist" 2>/dev/null |
while read -r p; do
  if grep -Eiq 'clip|clipboard|paste|menubar|menu bar' "$p"; then
    echo "$p"
    /usr/libexec/PlistBuddy -c 'Print :Label' "$p" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c 'Print :ProgramArguments' "$p" 2>/dev/null || true
    echo
  fi
done

echo
echo "== applications =="
find \
  /Applications \
  "$HOME/Applications" \
  "$HOME/Wonderland" \
  "$HOME/Downloads" \
  "$HOME/Library/Application Support" \
  "$HOME/Library/Containers" \
  "$HOME/Library/Group Containers" \
  -maxdepth 6 \
  \( -iname "*clip*" -o -iname "*clipboard*" -o -iname "*paste*" -o -iname "*menubar*" -o -iname "*menu bar*" \) \
  2>/dev/null

echo
echo "== spotlight =="
mdfind 'kMDItemDisplayName == "*clip*"cd || kMDItemDisplayName == "*clipboard*"cd || kMDItemDisplayName == "*paste*"cd || kMDItemDisplayName == "*menubar*"cd'
