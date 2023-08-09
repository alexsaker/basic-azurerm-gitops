# basic azurerm

This is the basic azurrm example for TF controller.
Assuming that you have a Flux-ready cluster running, you can GitOps the resource here by defining a source (GitRepository), then defining a Terraform object and attach it to the source, like the following.

```yaml
---
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: basicazurerm
  namespace: flux-system
spec:
  interval: 30s
  url: https://github.com/alexsaker/basic-azurerm-gitops
  ref:
    branch: main
---
apiVersion: infra.contrib.fluxcd.io/v1alpha2
kind: Terraform
metadata:
  name: basic-azurerm-tf
  namespace: flux-system
spec:
  path: ./
  interval: 1m
  sourceRef:
    kind: GitRepository
    name: basicazurerm
    namespace: flux-system
```

## Oci Image generation

If you are willing to use oci image of the terraform code you can build and push oci images with the following commands.

```bash
flux push artifact oci://ghcr.io/alexsaker/basicazurerm:$(git rev-parse --short HEAD) \
	--path="./" \
	--source="$(git config --get remote.origin.url)" \
	--revision="$(git branch --show-current)/$(git rev-parse HEAD)"


 flux tag artifact oci://ghcr.io/alexsaker/basicazurerm:$(git rev-parse --short HEAD) \
  --tag latest

# Create secret in Kubernetes 
kubectl -n flux-system create secret generic basicazurermcreds \
    --from-literal=client_id=xxxxxxxxxxxxxxx \
    --from-literal=client_secret=xxxxxxxxxxxxxx \
    --from-literal=tenant_id=xxxxxxxxxxxxxxxx \
    --from-literal=subscription_id=xxxxxxxxxxxxxxxxxx
```



```yaml
---
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: OCIRepository
metadata:
  name: basicazurerm
  namespace: flux-system
spec:
  interval: 5m
  url: oci://ghcr.io/alexsaker/basicazurerm
  ref:
    tag: latest
  provider: generic
  secretRef:
    name: ghcr-auth
---
apiVersion: infra.contrib.fluxcd.io/v1alpha2
kind: Terraform
metadata:
  name: basicazurerm-tf
  namespace: flux-system
spec:
  path: ./
  interval: 1m
  approvePlan: auto
  sourceRef:
    kind: OCIRepository
    name: basicazurerm
    namespace: flux-system
  vars:
    - name: subject
      value: Bobi
  writeOutputsToSecret:
    name: basicazurerm-output
```