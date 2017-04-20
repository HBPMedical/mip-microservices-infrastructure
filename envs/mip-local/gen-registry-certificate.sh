#!/bin/sh

[ -f etc/certs/registry.key ] || mkdir -p etc/certs && openssl req \
    -newkey rsa:4096 -nodes -sha256 \
    -x509 -days 365 -extensions v3_ca \
    -subj "/DC=CH/DC=CHUV/O=HBP/CN=registry.federation.mip.hbp" \
    -keyout etc/certs/registry.key \
    -out etc/certs/registry.crt
