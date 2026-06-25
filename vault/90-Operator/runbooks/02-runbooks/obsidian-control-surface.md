
Obsidian Control Surface Runbook
Purpose

Obsidian is the visible operating surface for Wonderland vault work.

Rule

Obsidian may launch governed intents, but runtime authority remains with shell commands under:

~/Wonderland/bin
List intents
wl obsidian list
Inspect an intent
wl obsidian show wl-status
Run an intent
wl obsidian run wl-status
Verify
wl obsidian verify
wl doctor
Rollback

Restore the previous router backup:

ls -t ~/Wonderland/.backup/router/wl.*.bak | head -1
cp "$(ls -t ~/Wonderland/.backup/router/wl.*.bak | head -1)" ~/Wonderland/bin/wl
chmod +x ~/Wonderland/bin/wl


## Governance Principle

This component may be destroyed and rebuilt without loss of authority.

Authority resides in:

- documented intent
- service definitions
- recovery procedures
- version-controlled governance records

Runtime state is disposable.
Authority is not.
