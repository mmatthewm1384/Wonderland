# Snapshot 20260606-083637

WL_HOME=/Users/wonderland/Wonderland
WL_DATA=/Users/wonderland/Wonderland/data

CONTAINER ID    IMAGE                                            COMMAND                   CREATED               STATUS    PORTS                     NAMES
9a995bdc6aca    docker.io/grafana/grafana:11.1.4                 "/run.sh"                 About a minute ago    Up        0.0.0.0:3000->3000/tcp    wl-grafana
485e0d598a9a    docker.io/grafana/loki:3.1.1                     "/usr/bin/loki -conf…"    About a minute ago    Up        0.0.0.0:3100->3100/tcp    wl-loki
22a82b1250eb    docker.io/prom/prometheus:v2.54.1                "/bin/prometheus --c…"    About a minute ago    Up        0.0.0.0:9090->9090/tcp    wl-prometheus
6bf1dbde9d62    docker.io/library/nats:2.10                      "/nats-server -js -m…"    About a minute ago    Up        0.0.0.0:8222->8222/tcp    wl-nats
8148ce589129    docker.io/coredns/coredns:1.11.3                 "/coredns -conf /etc…"    About a minute ago    Up        0.0.0.0:1053->53/tcp      wl-dns
85ff15930f3d    docker.io/library/anon-vm-anon-gateway:latest    "/usr/local/bin/entr…"    3 days ago            Up                                  anon-gateway
