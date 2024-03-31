# Clusters mono-repo for homelab

This git repository stores the current state of my k8s cluster(s), which currently comprises a of single main cluster and occasionally a local test one.
My "physical" infrastructure that underlies kubernetes is configured in my infrastructure git repository found here: https://github.com/sakura-dragon/infrastructure.

My main cluster is mostly based around:

- Local storage (as it's running on virtualised infrastructure)
- Istio for ingress (mostly for research, but also as it seems very feature rich)
- Cloudflared for publicly accessible ingress (no port-forwarding required and protected, hopefully, by cloudflares security)
- Keycloak for centralised Authn and Authz

Directories:

- clusters: sub-directory per cluster, main entrypoint for flux
- common: resources that may be common between different clusters
- apps:
  - base: base applications, as generic as possible if I wanted to deploy it multiple times
  - additional directories per cluster for describing any "apps" or services.

# Local testing

There is a `local-cluster.yaml` config file that can be used with [kind](https://kind.sigs.k8s.io) to setup a local k8s cluster for testing purposes.

To configure a local cluster you will want to checkout this git repository locally and ensure that `$LOCAL_DOMAIN` is set to a hostname that resolves to `127.0.0.1`.

```bash
# Create the local kind cluster
kind create cluster --config=local-cluster.yaml
# Ensure flux is installed
curl -s https://fluxcd.io/install.sh | sudo bash
# Flux pre-flight checks
flux check --pre
# Provision the kind cluster
# Note: This will want running twice as the CRD's don't exist the first time this command is run
kubectl kustomize ./clusters/local/flux-system/ | kubectl apply -f -
# Create a secret for provisions the apps cluster with
kubectl create secret generic app-vars -n flux-system --from-literal=LOCAL_DOMAIN=$LOCAL_DOMAIN
```

Note: Grafana is deployed to `http://$LOCAL_DOMAIN/grafana` with the default credentials of `admin:prom-operator`, as this is only running over `127.0.0.1` there is no requirement for this to be secure.

# Main Cluster

I'm using Hashicorp Vault to store and maintain the majority of the secrets in my cluster. But to do so requires telling the secret-csi provider where vault is. So for the "non-sensitive" secrets values of domains and where to find vault, they're encrypted using sops+age in this repo.

Given that the secret values are easily re-created, I'm not concerned about the loss of the generated age key. Hence, to make the cluster specific age key:
```bash
age-keygen -o age.agekey
cat age.agekey |
kubectl create secret generic sops-age \
--namespace=flux-system \
--from-file=age.agekey=/dev/stdin
SOPS_AGE_KEY_FILE=age.agekey sops clusters/main/base/cluster-vars.sops.yaml
```
Technically the `SOPS_AGE_KEY_FILE` is not needed for just encrypting, but is needed during decryption/reading.

The above `sops` command depends on the [.sops.yaml](./clusters/main/.sops.yaml) config file in the relevant directory:
```yaml
creation_rules:
- path_regex: '.*.sops.yaml$'
  encrypted_regex: ^(data|stringData)$
  age: 'xxxxxxxxxx'
```

> Note: Probably the "more secure" way of doing this is as I've done for the local cluster above. These settings only exist here and are not likely to change often, having them set and used only where they are consumed makes more sense especially given the values are memorable and can be re-created easily. But I'm using this more as a live demo that can be referenced in the future. Plus, if someone wants to go through the effort of decrypting the age encryption of the secret values, then this is likely a targeted attack anyway, and they could likely find out the domain names through other means. That, or age encryption is broken and I should probably not be using it.
