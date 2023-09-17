# Continious Deployment Example

## Cluster

Create KinD cluster and export kubeconfig file:

```bash
$ kind create cluster --name develop
$ kind export kubeconfig --name develop --kubeconfig kubeconfig
```

## Hosts

Create a Python virtual environment and update Hosts:

```shell
$ python3 -m venv venv
$ source venv/bin/activate
$ pip install -r scripts/requirements.txt
$ python3 -m scripts.update_hosts
```
