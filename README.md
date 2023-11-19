# Clusters mono-repo for homelab

Stores the current state of my k8s clusters, which currently comprises a single main cluster.

My main cluster is mostly based around:
* Local storage (as it's running on virtualised infrastructure)
* Istio for ingress (mostly for research, but also it is very feature rich)
* Cloudflared for publicly accessible ingress (no port-forwarding required and protected, hopefully, by cloudflares security)
* Keycloak for centralised Authn and Authz


Directories:
* clusters: sub-directory per cluster, main entrypoint for flux
* common: resources that may be common between different clusters
* apps: 
    * base: base applications, as generic as possible if I wanted to deploy it multiple times
    * additional directories per cluster for describing any "apps" or services.

# Local testing

There is a `local-cluster.yaml` config file that can be used with [kind](https://kind.sigs.k8s.io) to setup a local k8s cluster for testing purposes.

```bash
# Create the local kind cluster
kind create cluster --config=local-cluster.yaml
# Ensure flux is installed
curl -s https://fluxcd.io/install.sh | sudo bash
# Flux pre-flight checks
flux check --pre
# Provision the kind cluster
kubectl kustomize  ./clusters/local/flux-system/  | kubectl apply -f -
# Create a secret for provisions the apps cluster with
kubectl create secret generic app-vars -n flux-system --from-literal=LOCAL_DOMAIN=$LOCAL_DOMAIN
```
