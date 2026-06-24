FROM alpine:3.20
RUN apk add --no-cache ca-certificates wget bash coreutils tar findutils nano less

ARG AGE_VERSION=1.3.1

RUN set -e; \
    echo "Downloading age v${AGE_VERSION}..."; \
    if ! wget -O /tmp/age.tar.gz "https://dl.filippo.io/age/v${AGE_VERSION}?for=linux/arm64"; then \
        echo "ERROR: wget failed."; exit 1; \
    fi; \
    echo "Extracting..."; \
    tar xzf /tmp/age.tar.gz --strip-components=1 -C /usr/local/bin; \
    rm -f /tmp/age.tar.gz; \
    chmod +x /usr/local/bin/age*; \
    echo "age v${AGE_VERSION} installed successfully."
    COPY scripts/ /scripts/
    RUN chmod +x /scripts/inside/veil-session.sh
