
Wonderland Operations
Check Status
wl-unified status
curl -s http://127.0.0.1:9105/api/v1/ready | jq
Dashboard
open http://127.0.0.1:9110
Release Build
wl-release build
Platform Freeze
wl-platform-freeze
Backup
wl-backup create
wl-backup verify
wl-backup preview
Logs
tail -100 runtime/controller/api-v2.err.log
tail -100 runtime/controller/api-v2.out.log
tail -100 runtime/controller/dashboard.err.log
tail -100 runtime/controller/dashboard.out.log

