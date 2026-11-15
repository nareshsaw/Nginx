# NGINX Reverse Proxy & Kubernetes Ingress Lab

![CI](https://github.com/nareshsaw/Nginx/actions/workflows/ci.yml/badge.svg)

A hands-on lab covering NGINX as a **reverse proxy and load balancer** (Docker Compose) and as a **Kubernetes Ingress controller** (ingress-nginx on kind), with automated tests on GitHub Actions.

## What it demonstrates

| Area | Docker Compose (NGINX) | Kubernetes (ingress-nginx) |
|---|---|---|
| Load balancing | `least_conn` upstream across 2 services, keepalive | Service load balancing across 2 replicas per app |
| Health | Passive health checks (`max_fails`, `fail_timeout`), retry on next upstream | Readiness probes |
| TLS | TLS 1.2/1.3, HTTP/2, HTTP→HTTPS redirect | TLS secret on the Ingress, SSL redirect |
| Traffic control | Rate limiting 10 r/s per IP (429 on excess) | `limit-rps` annotation |
| Routing | Single upstream pool | Path-based routing `/app1`, `/app2` |
| Security | HSTS, nosniff, frame-deny headers, `server_tokens off` | — |
| Observability | JSON access logs, `stub_status` | — |

## Architecture

```
            Docker Compose                              Kubernetes (kind)
client ──HTTPS──▶ NGINX ──least_conn──▶ app1      client ──HTTPS──▶ ingress-nginx ──/app1──▶ Service app1 ──▶ 2 pods
                    │                 └▶ app2                              └──/app2──▶ Service app2 ──▶ 2 pods
```

## Run it locally

Prerequisites: Docker, `openssl`, `curl`; for Kubernetes also `kind` and `kubectl`.

### 1. NGINX reverse proxy (Docker Compose)

```bash
./scripts/gen-certs.sh
docker compose -f docker/docker-compose.yml up -d
docker compose -f docker/docker-compose.yml exec nginx nginx -t
./scripts/test-lb.sh
docker compose -f docker/docker-compose.yml down
```

### 2. Kubernetes Ingress (kind + ingress-nginx)

```bash
kind create cluster --name nginx-lab --config k8s/kind-config.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.3/deploy/static/provider/kind/deploy.yaml
kubectl wait -n ingress-nginx --for=condition=ready pod -l app.kubernetes.io/component=controller --timeout=180s

./scripts/gen-certs.sh
kubectl apply -f k8s/apps.yaml
kubectl create secret tls lab-tls -n nginx-lab --cert=certs/lab.crt --key=certs/lab.key
kubectl apply -f k8s/ingress.yaml

curl -sk --resolve lab.local:443:127.0.0.1 https://lab.local/app1
curl -sk --resolve lab.local:443:127.0.0.1 https://lab.local/app2
kind delete cluster --name nginx-lab
```

## CI

Every push runs `.github/workflows/ci.yml`: it starts the Compose stack, validates the config with `nginx -t`, runs the smoke tests, then creates a kind cluster, installs ingress-nginx and tests TLS + path routing.

## Results

<!-- Paste your own test output here after running ./scripts/test-lb.sh -->

## What I learned

<!-- Write 3–5 points in your own words, e.g. a problem you hit and how you fixed it -->
