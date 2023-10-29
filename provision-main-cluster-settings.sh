#!/usr/bin/env bash
set -e

kubectl apply -f - <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: cloudflared
  namespace: cloudflared
data:
  tunnel-token: $(echo "$CLOUDFLARED_TOKEN" | base64 --wrap=0)
---
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-token
  namespace: cert-manager
data:
  api-token: $(echo "$CLOUDFLARE_API_TOKEN" | base64 --wrap=0)
---
apiVersion: v1
kind: Secret
metadata:
  name: cluster-vars
  namespace: flux-system
data:
  LOAD_BALANCER_IP_POOL: $(echo "$LOAD_BALANCER_IP_POOL" | base64 --wrap=0)
  PUBLIC_DOMAIN: $(echo "$PUBLIC_DOMAIN" | base64 --wrap=0)
  PRIVATE_DOMAIN: $(echo "$PUBLIC_DOMAIN" | base64 --wrap=0)
---
apiVersion: v1
kind: Secret
metadata:
  name: app-vars
  namespace: flux-system
data:
  PUBLIC_DOMAIN: $(echo "$PUBLIC_DOMAIN" | base64 --wrap=0)
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: cloudflare
  namespace: cert-manager
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: "${CLOUDFLARE_EMAIL}"
    privateKeySecretRef:
      name: cloudflare-privkey
    solvers:
    - dns01:
        cloudflare:
          email: "${CLOUDFLARE_EMAIL}"
          apiTokenSecretRef:
            name: cloudflare-api-token
            key: api-token
EOF
