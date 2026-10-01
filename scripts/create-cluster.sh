#!/usr/bin/env bash
set -euo pipefail
k3d cluster delete cassandra-platform 2>/dev/null || true
k3d cluster create cassandra-platform \
  --api-port 6550 --servers 1 --agents 3 \
  --port "80:80@loadbalancer" --port "443:443@loadbalancer"
kubectl get nodes
