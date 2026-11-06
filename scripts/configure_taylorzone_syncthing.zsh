#!/bin/zsh
set -euo pipefail

# ====================================================================
# TaylorZone Syncthing REST API Folder Provisioner (Array Schema Fix)
# ====================================================================

python3 - << 'EOF'
import os
import sys
import json
import urllib.request
import ssl

xml_path = os.path.expanduser("~/Library/Application Support/Syncthing/config.xml")

print("[+] Extracting Syncthing API key and configuration...")
try:
    import xml.etree.ElementTree as ET
    tree = ET.parse(xml_path)
    root = tree.getroot()
    key_el = root.find(".//gui/apikey")
    api_key = key_el.text if key_el is not None and key_el.text else ""
except Exception as e:
    print(f"[-] Error parsing config.xml: {e}", file=sys.stderr)
    sys.exit(1)

if not api_key:
    print("[-] Error: Empty API key found in config.xml.", file=sys.stderr)
    sys.exit(1)

print("[+] Successfully extracted Syncthing API key.")

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

base_url = "https://127.0.0.1:8384"
headers = {"X-API-Key": api_key}

# 1. Fetch System Status to get local Device ID
status_url = f"{base_url}/rest/system/status"
try:
    req = urllib.request.Request(status_url, headers=headers)
    with urllib.request.urlopen(req, context=ctx, timeout=10) as response:
        status_data = json.loads(response.read().decode("utf-8"))
        local_device_id = status_data.get("myID", "")
except Exception as e:
    print(f"[-] Error fetching Syncthing status: {e}", file=sys.stderr)
    sys.exit(1)

if not local_device_id:
    print("[-] Error: Could not resolve local device ID from Syncthing API.", file=sys.stderr)
    sys.exit(1)

print(f"[+] Local Device ID resolved: {local_device_id}")

# 2. Construct Folder Configuration Payload as an Array
folder_payload = [
    {
        "id": "taylorzone-shared-assets",
        "label": "TaylorZone Shared Assets",
        "path": "/Volumes/TaylorZone/shared_assets",
        "type": "sendreceive",
        "devices": [
            {
                "deviceID": local_device_id,
                "introducedBy": ""
            }
        ],
        "rescanIntervalS": 3600,
        "fsWatcherEnabled": True,
        "fsWatcherDelayS": 10,
        "ignorePerms": False,
        "autoNormalize": True,
        "minDiskFree": {
            "value": 5,
            "unit": "%"
        },
        "versioning": {
            "type": "staggered",
            "params": {
                "cleanInterval": "3600",
                "maxAge": "7776000"
            }
        },
        "copiers": 0,
        "pullerMaxPendingKiB": 0,
        "hashers": 0,
        "order": "random",
        "ignoreDelete": False,
        "scanProgressIntervalS": 0,
        "pullerPauseS": 0,
        "maxConflicts": 10,
        "disableSparseFiles": False,
        "disableTempIndexes": False,
        "paused": False,
        "weakHashThresholdPct": 100,
        "markerName": ".stfolder",
        "useLargeBlocks": True
    }
]

# 3. PUT Folder Configuration
folder_url = f"{base_url}/rest/config/folders"
data_bytes = json.dumps(folder_payload).encode("utf-8")

print("[+] Pushing folder configuration array to Syncthing REST API...")
try:
    put_req = urllib.request.Request(folder_url, data=data_bytes, headers={**headers, "Content-Type": "application/json"}, method="PUT")
    with urllib.request.urlopen(put_req, context=ctx, timeout=10) as resp:
        if 200 <= resp.status < 300:
            print("[+] TaylorZone shared_assets folder successfully provisioned!")
        else:
            print(f"[-] Failed to provision folder. HTTP Status: {resp.status}", file=sys.stderr)
            sys.exit(1)
except urllib.error.HTTPError as e:
    body = e.read().decode("utf-8")
    print(f"[-] HTTP Error {e.code}: {body}", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f"[-] Error pushing configuration: {e}", file=sys.stderr)
    sys.exit(1)

# 4. Trigger Restart to apply configuration
restart_url = f"{base_url}/rest/system/restart"
try:
    post_req = urllib.request.Request(restart_url, headers=headers, method="POST")
    with urllib.request.urlopen(post_req, context=ctx, timeout=10) as resp:
        print("[+] Syncthing configuration reloaded successfully.")
except Exception as e:
    print(f"[!] Warning: Could not trigger automatic restart: {e}")

EOF
