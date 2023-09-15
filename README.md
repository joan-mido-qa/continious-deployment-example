# Continious Deployment Example

## Cluster

Create KinD cluster and export kubeconfig file:

```bash
$ kind create cluster --name develop
$ kind export kubeconfig --name develop --kubeconfig kubeconfig
```
