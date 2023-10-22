#!/usr/bin/env bash
set -e

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: cluster-vars
  namespace: flux-system
data:
  LOAD_BALANCER_IP_POOL: $(echo "$1" | base64 --wrap=0)
EOF
