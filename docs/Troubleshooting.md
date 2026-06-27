
Wonderland Troubleshooting
API Unavailable
lsof -nP -iTCP:9105 -sTCP:LISTEN
tail -100 runtime/controller/api-v2.err.log
launchctl kickstart -k gui/$(id -u)/com.wonderland.controller-v2-api
Dashboard Unavailable
lsof -nP -iTCP:9110 -sTCP:LISTEN
tail -100 runtime/controller/dashboard.err.log
launchctl kickstart -k gui/$(id -u)/com.wonderland.dashboard
Runtime Checks
limactl list
limactl shell wonderland-rootless nerdctl ps
Certification Failure
wl-test
wl-schema
wl-openapi
wl-policy
wl-release certify
Plugin Failure

Plugins are optional. If plugin loading fails, the controller should continue using the null plugin manager.

wl-plugins
curl -s http://127.0.0.1:9105/api/v1/plugins | jq

