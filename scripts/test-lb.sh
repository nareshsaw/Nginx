#!/usr/bin/env bash
# Smoke tests for the Docker Compose setup
set -euo pipefail
URL="https://localhost:8443"

echo "1) Health check"
curl -sk "$URL/healthz"

echo "2) HTTP -> HTTPS redirect"
curl -s -o /dev/null -w "   status %{http_code} -> %{redirect_url}\n" http://localhost:8080/

echo "3) Load balancing across app1 and app2 (20 requests)"
for i in $(seq 1 20); do curl -sk "$URL/"; done | sort | uniq -c

echo "4) Rate limiting (60 fast requests, expect some 429s)"
for i in $(seq 1 60); do curl -sk -o /dev/null -w "%{http_code}\n" "$URL/"; done | sort | uniq -c

echo "5) TLS version negotiated"
curl -skv "$URL/" 2>&1 | grep -E "SSL connection using" || true
