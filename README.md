# AKS Istio Setup with public & internal ingress

## Overview

This guide showcases how to install falco in AKS with FluxCD.

## Requirements

To run with `bootstrap.sh` script, the following CLI tools need to be installed:
- terraform
- az
- gh
- flux
- kubectl (optional, only needed if you are running the test app)

## Steps

### Setup Infra

Before you do anything, please check the following:

- Check `bootstrap.sh` and change the local variables you prefer.
- Check `terraform/terraform.tfvars` and change to whichever defaults you prefer.


First login with your az login account:
```sh
az login
```

Then run the `bootstrap.sh` script:
```sh
./bootstrap.sh
```

The `bootstrap.sh`:
- Creates an AKS cluster
- Installs `FluxCD`
- Through `FluxCD`, installs the `Falco` charts.


### Test Sample App

```sh
kubectl create deploy mytest --image=nginx

kubectl exec -it $(kubectl get po -l app=mytest -oname) -- sh

```

## References

- [Falco Event Generator in k8s](https://falco.org/docs/event-sources/sample-events)
- [Falco + Falcosidekick + Falcosidekick-ui](https://github.com/falcosecurity/charts/tree/master/falcosidekick#with-helm-chart-of-falco)
- [How to start a pod with root & host namespaces](https://downey.io/notes/dev/kubernetes-privileged-root-pod-example)
- [K8s Docs about mounting Unix Sockets](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath)
- [How to create a pod with a shell script in a ConfigMap](https://stackoverflow.com/questions/33887194/how-to-set-multiple-commands-in-one-yaml-file-with-kubernetes)
- [How to use the timeout command](https://stackoverflow.com/questions/7851889/kill-process-after-a-given-time-bash)
- [The timeout command docs](https://www.gnu.org/software/coreutils/manual/html_node/timeout-invocation.html)
