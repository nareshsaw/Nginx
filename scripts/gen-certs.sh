#!/usr/bin/env bash
# Creates a self-signed TLS certificate for lab.local / localhost
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p certs
openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout certs/lab.key -out certs/lab.crt \
  -subj "/CN=lab.local" \
  -addext "subjectAltName=DNS:lab.local,DNS:localhost"
echo "Certificate written to certs/lab.crt"
