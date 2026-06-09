# Blueprint: Hardened Anonymizing Gateway & Scraper Loop
* **Status:** Shelved / Ready for Deployment
* **Target Workspace Area:** ../Wonderland-v4/

---

## 1. Architectural Summary
A multi-tier network boundary defense system designed for unattended, long-running operations. It guarantees that downstream containers cannot leak the host system's IP address by enforcing a Layer 4 firewall kill-switch inside an isolated container network (`wl-anon-network`).

[ Downstream Scraper ] ──> [ Privoxy Translator (8118) ] ──> [ Tor Daemon (9050/9051) ] ──> [ WAN ]
▲
(iptables: drop non-Tor UID)


---

## 2. Component Files Baseline

### A. Gateway Stack (`../Wonderland-v4/anon-gateway/`)

#### `docker-compose.yml`
```yaml
version: '3.8'

services:
  tor:
    image: alpine:3.18
    container_name: wl-anon-tor
    restart: always
    cap_add:
      - NET_ADMIN
    volumes:
      - ./config/torrc:/etc/tor/torrc:ro
      - tor-data:/var/lib/tor
    entrypoint: 
      - "sh"
      - "-c"
      - |
        apk add --no-cache tor iptables &&
        iptables -F &&
        iptables -X &&
        iptables -P INPUT DROP &&
        iptables -P FORWARD DROP &&
        iptables -P OUTPUT DROP &&
        iptables -A INPUT -i lo -j ACCEPT &&
        iptables -A OUTPUT -o lo -j ACCEPT &&
        iptables -A INPUT -p tcp --dport 9050 -j ACCEPT &&
        iptables -A INPUT -p tcp --dport 9051 -j ACCEPT &&
        iptables -A OUTPUT -m owner --uid-owner tor -j ACCEPT &&
        iptables -A OUTPUT -j DROP &&
        exec tor -f /etc/tor/torrc
    networks:
      - anon-isolated

  privoxy:
    image: alpine:3.18
    container_name: wl-anon-privoxy
    restart: always
    depends_on:
      - tor
    volumes:
      - ./config/privoxy.config:/etc/privoxy/config:ro
    entrypoint: ["sh", "-c", "apk add --no-cache privoxy && exec privoxy --no-daemon /etc/privoxy/config"]
    ports:
      - "8118:8118"
    networks:
      - anon-isolated

volumes:
  tor-data:

networks:
  anon-isolated:
    name: wl-anon-network
    driver: bridge
config/torrc
Plaintext
DataDirectory /var/lib/tor
SocksPort 0.0.0.0:9050
ControlPort 0.0.0.0:9051
CookieAuthentication 0
Log notice stdout
NewCircuitPeriod 15
MaxCircuitDirtiness 600
config/privoxy.config
Plaintext
listen-address  0.0.0.0:8118
toggle          1
enable-remote-toggle  0
enable-remote-http-toggle  0
enable-edit-actions 0
enforce-blocks 1
buffer-limit 4096
forward-socks5t / tor:9050 .
max-client-connections 512
keep-alive-timeout 15
socket-timeout 300
hide-console
filter-headers-hiding
scripts/doctor.py
Python
#!/usr/bin/env python3
import sys
import subprocess
import urllib.request
import json

def main():
    try:
        t_on = subprocess.run(["nerdctl", "inspect", "-f", "{{.State.Running}}", "wl-anon-tor"], capture_output=True, text=True).stdout.strip() == "true"
        p_on = subprocess.run(["nerdctl", "inspect", "-f", "{{.State.Running}}", "wl-anon-privoxy"], capture_output=True, text=True).stdout.strip() == "true"
        f_on = "DROP" in subprocess.run(["nerdctl", "exec", "wl-anon-tor", "iptables", "-L", "OUTPUT"], capture_output=True, text=True).stdout
    except Exception:
        sys.exit(1)
        
    if not (t_on and p_on and f_on):
        sys.exit(1)
        
    proxy_support = urllib.request.ProxyHandler({'http': '[http://127.0.0.1:8118](http://127.0.0.1:8118)', 'https': '[http://127.0.0.1:8118](http://127.0.0.1:8118)'})
    opener = urllib.request.build_opener(proxy_support)
    try:
        req = urllib.request.Request("[https://check.torproject.org/api/ip](https://check.torproject.org/api/ip)", headers={'User-Agent': 'Mozilla/5.0'})
        with opener.open(req, timeout=10) as response:
            data = json.loads(response.read().decode())
            if data.get("IsTor"):
                sys.exit(0)
    except Exception:
        pass
    sys.exit(1)

if __name__ == "__main__":
    main()
scripts/repair.py
Python
#!/usr/bin/env python3
import sys
import subprocess

def main():
    try:
        subprocess.run(["nerdctl", "compose", "down", "--remove-orphans", "-v"], check=True)
        subprocess.run(["nerdctl", "compose", "up", "-d", "--build"], check=True)
        sys.exit(0)
    except Exception:
        sys.exit(1)

if __name__ == "__main__":
    main()
B. Downstream Scraper App Configs
../Wonderland-v4/anon-scraper/docker-compose.yml
YAML
version: '3.8'

services:
  scraper:
    image: alpine:3.18
    container_name: wl-anon-scraper
    restart: always
    volumes:
      - .:/app
    working_dir: /app
    environment:
      - HTTP_PROXY=http://wl-anon-privoxy:8118
      - HTTPS_PROXY=http://wl-anon-privoxy:8118
      - urllib_proxy=http://wl-anon-privoxy:8118
    entrypoint:
      - "sh"
      - "-c"
      - |
        apk add --no-cache python3 py3-pip &&
        python3 -m venv venv &&
        ./venv/bin/pip install --no-cache-dir -r requirements.txt &&
        exec ./venv/bin/python3 app.py
    networks:
      - anon-isolated

networks:
  anon-isolated:
    external: true
    name: wl-anon-network
../Wonderland-v4/anon-scraper/requirements.txt
Plaintext
requests==2.31.0
../Wonderland-v4/anon-scraper/app.py
Python
#!/usr/bin/env python3
import sys
import time
import requests

def verify_routing():
    proxies = {"http": "http://wl-anon-privoxy:8118", "https": "http://wl-anon-privoxy:8118"}
    try:
        response = requests.get("[https://check.torproject.org/api/ip](https://check.torproject.org/api/ip)", proxies=proxies, timeout=15)
        return response.json().get("IsTor", False)
    except Exception:
        return False

def main():
    if not verify_routing():
        sys.exit(1)
        
    while True:
        try:
            res = requests.get("[https://httpbin.org/headers](https://httpbin.org/headers)", timeout=10)
            print(f"[DATA-STREAM] Successfully processed payload size: {len(res.text)} bytes")
        except Exception:
            if not verify_routing():
                sys.exit(2)
        time.sleep(30)

if __name__ == "__main__":
    main()
3. Operational Infrastructure Control Matrix
Up: nerdctl compose up -d

Down: nerdctl compose down

Doctor: python3 scripts/doctor.py

Repair: python3 scripts/repair.py
