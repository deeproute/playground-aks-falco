# AKS Falco Benchmark

## Overview

This guide showcases how to install a falco benchmark tool in AKS with FluxCD.

## Requirements

To run with `bootstrap.sh` script, the following CLI tools need to be installed:
- terraform
- az
- gh
- flux
- kubectl (optional, only needed if you are running the test app)

## Infrastructure

Before you do anything, please check the following:

- Fork this repo into your github account
- Check `bootstrap.sh` and change your github user and any other local variables you need.
- Check `terraform/terraform.tfvars` and change to whichever defaults you prefer.

Login with your azure account:
```sh
az login
```

Login with your github:
```sh
gh auth login

# Retrieve the github token
gh auth status -t

# Copy it to the environment var
export GITHUB_TOKEN=<token>
```

Then run the `bootstrap.sh` script:
```sh
./bootstrap.sh
```

The `bootstrap.sh`:
- Creates an AKS cluster with `terraform` CLI.
- Installs `FluxCD` with the `flux` CLI.
- Through `FluxCD`, installs the `Falco` charts.

## Benchmark Falco to trigger Syscall event drops

### Configuration

Check the following files:
- For the infrastructure setup: [terraform.tfvars](terraform/terraform.tfvars)
- For the Falco DaemonSet config: [release-bench.yaml](fluxcd/infrastructure/falco/release-bench.yaml)
- For the Event Generator Shell Script: [script-configmap.yaml](fluxcd/infrastructure/falco-event-generator/script-configmap.yaml)

### How the benchmark was performed

When you complete the bootstrap process the Falco `Event Generator` job will start automatically when the `Falco Daemonset` is ready.
The job is configured to run for 5 minutes which totals about 30 rounds. Each round will increase the number of events generated.
The main metrics are the `EPS` (events per second) and the `% lost`.

If you wish to change the falco benchmark parameters change it in [release-bench.yaml](fluxcd/infrastructure/falco/release-bench.yaml).

More specifically:
- resources:
```yaml
resources:
  requests:
    cpu: 100m
    memory: 512Mi
  limits:
    cpu: 1000m
    memory: 1024Mi
```

- eBPF flag:
```yaml
ebpf:
  enabled: true
```

- Buffered Output flag:
```yaml
falco:
  bufferedOutputs: true
```

After you perform the change, do the following:
- Wait for the `Falco daemonset` to be ready
- Delete the `Event Generator` Job so `fluxcd` will synch it again and start over the benchmark:
```sh
kubectl -n falco delete job falco-event-generator
```
- When the job completes, check the job pod's logs:
```sh
kubectl -n falco logs falco-event-generator-xxxxx
```

### Benchmark Reports

Below is the various ways that I benchmarked the `Falco` pod. Check the reports in the [benchmarks](benchmarks) folder.
The most interesting column is the `Avg. Success EPS`. The higher the better. The formula is `EPS round with drops` x `% Success`.

| Falco Config |     |      |        |  Results |                      |           |             |                                                        |
|--------------|-----|------|--------|----------|----------------------|-----------|-------------|--------------------------------------------------------|
| CPUs         | Mem | eBPF | Buffer | Round    | EPS round with drops | % Success | Avg. EPS    | Report File                                            |
| 1            | 1Gi | No   | No     | 16       | 11134.6              | 89.90%    | 10010.0054  | falco-event-generator-ebpf-no-buffer-no-1cpu-1Gi.txt   |
| 2            | 1Gi | No   | No     | 20       | 25312.2              | 62.69%    | 15868.21818 | falco-event-generator-ebpf-no-buffer-no-2cpu-1Gi.txt   |
| 1            | 1Gi | Yes  | No     | 16       | 10362.6              | 89.30%    | 9253.8018   | falco-event-generator-ebpf-yes-buffer-no-1cpu-1Gi.txt  |
| 2            | 1Gi | Yes  | No     | 21       | 19146.6              | 71.50%    | 13689.819   | falco-event-generator-ebpf-yes-buffer-no-2cpu-1Gi.txt  |
| 1            | 1Gi | Yes  | Yes    | 15       | 9180.2               | 93.80%    | 8611.0276   | falco-event-generator-ebpf-yes-buffer-yes-1cpu-1Gi.txt |
| 2            | 1Gi | Yes  | Yes    | 20       | 17703.2              | 76.40%    | 13525.2448  | falco-event-generator-ebpf-yes-buffer-yes-2cpu-1Gi.txt |

### Benchmark Observations

- The higher the number of CPUs, the better `Falco` performs.
- Using `eBPF` is slower
- Using `Buffer` is slower
- Increasing the memory doesn't affect performance


## Falco References

- [Performance Testing](https://falco.org/blog/falco-performance-testing)
- [Event Generator in k8s](https://falco.org/docs/event-sources/sample-events)
- [Actions for dropped system call events](https://falco.org/docs/event-sources/dropped-events)
- [GH Issue syscall drops](https://github.com/falcosecurity/falco/issues/1870)
- [Falco Helm Chart Values](https://github.com/falcosecurity/charts/blob/master/falco/values.yaml)
- [Falco + Falcosidekick + Falcosidekick-ui](https://github.com/falcosecurity/charts/tree/master/falcosidekick#with-helm-chart-of-falco)


## Other References

- [How to start a pod with root & host namespaces](https://downey.io/notes/dev/kubernetes-privileged-root-pod-example)
- [K8s Docs about mounting Unix Sockets](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath)
- [How to create a pod with a shell script in a ConfigMap](https://stackoverflow.com/questions/33887194/how-to-set-multiple-commands-in-one-yaml-file-with-kubernetes)
- [How to use the timeout command](https://stackoverflow.com/questions/7851889/kill-process-after-a-given-time-bash)
- [The timeout command docs](https://www.gnu.org/software/coreutils/manual/html_node/timeout-invocation.html)