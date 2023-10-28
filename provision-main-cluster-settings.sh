#!/usr/bin/env bash
set -e

if test "$#" -ne 2; then
    echo "Please specifiy the following positional argumets <CLOUDFLARE_TOEKN> <LOADBALANCER_IP_RANGE>"
    exit
fi


kubectl apply -f - <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: cloudflared
  namespace: istio-system
stringData:
  tunnel-token: "$1"
---
apiVersion: v1
kind: Secret
metadata:
  name: cluster-vars
  namespace: flux-system
stringData:
  LOAD_BALANCER_IP_POOL: "$2"
EOF
