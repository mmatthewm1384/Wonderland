# Wonderland Runtime Certification

Sun Jun 21 06:55:00 PDT 2026

Wonderland Universe Status

Root:  /Users/wonderland/Wonderland
Mode:  full

Authority
PASS mode                   
PASS storage                
PASS storage authority      

Governance
PASS governance             
PASS recovery               
PASS snapshot               

Runtime
PASS dns                    
PASS nats                   
PASS observability          

Capability
PASS media                  
PASS torrent                

RESULT PASS

## Containers
wl-grafana Up 0.0.0.0:3000->3000/tcp
wl-prometheus Up 0.0.0.0:9090->9090/tcp
wl-loki Up 0.0.0.0:3100->3100/tcp
wl-nats Up 0.0.0.0:4222->4222, 8222->8222/tcp
wl-dns Up 0.0.0.0:1053->53/tcp, 0.0.0.0:1053->53/udp
wl-portainer Up 0.0.0.0:9443->9443/tcp
wl-sandbox Up 
wl-torrent-vpn Up 127.0.0.1:9091->9091/tcp
wl-seed Up 
wl-document-cleaner Up 127.0.0.1:8788->8788/tcp
wl-anon-scraper Up 
wl-anon-tor Up 0.0.0.0:9050->9050/tcp
