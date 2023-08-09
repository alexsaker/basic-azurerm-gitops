# helloworld

This is the hello world example for TF controller.
Assuming that you have a Flux-ready cluster running, you can GitOps the resource here by defining a source (GitRepository), then defining a Terraform object and attach it to the source, like the following.

```yaml
---
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: helloworld
  namespace: flux-system
spec:
  interval: 30s
  url: https://github.com/alexsaker/helloworld-gitops
  ref:
    branch: main
---
apiVersion: infra.contrib.fluxcd.io/v1alpha2
kind: Terraform
metadata:
  name: helloworld-tf
  namespace: flux-system
spec:
  path: ./
  interval: 1m
  sourceRef:
    kind: GitRepository
    name: helloworld
    namespace: flux-system
```

## Oci Image generation

If you are willing to use oci image of the terraform code you can build and push oci images with the following commands.

```bash
flux push artifact oci://ghcr.io/alexsaker/helloworld:$(git rev-parse --short HEAD) \
	--path="./" \
	--source="$(git config --get remote.origin.url)" \
	--revision="$(git branch --show-current)/$(git rev-parse HEAD)"


 flux tag artifact oci://ghcr.io/alexsaker/helloworld:$(git rev-parse --short HEAD) \
  --tag latest
```