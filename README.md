# Continious Deployment Example

This repository contains an example of a continious deployment pipeline using FluxCD and Flagger.

## Requirements

- [Python](https://www.python.org)
- [Terraform](https://www.terraform.io)
- [TFSec](https://github.com/aquasecurity/tfsec)
- [TFLint](https://github.com/aquasecurity/tfsec)
- [Docker](https://www.docker.com)
- [KinD](https://kind.sigs.k8s.io/docs/user/quick-start/)

## Cluster

Create KinD cluster and export kubeconfig file:

```bash
$ kind create cluster --name develop
$ kind export kubeconfig --name develop --kubeconfig kubeconfig
```

Initialize Terraform and apply the changes to the cluster. Terraform requires as input a GitHub token with repository read/write permissions:

```bash
$ cd terraform
$ terraform init
$ terraform apply -var="github_owner=owner_name" -var="github_repository=repo_name"
```

Terraform installs MetalLB and sets the IP ranges. Then, install FluxCD Chart and set up the GitHub repository.

## Hosts

Create a Python virtual environment and update Hosts:

```shell
$ python3 -m venv venv
$ source venv/bin/activate
$ pip install -r scripts/requirements.txt
$ python3 -m scripts.update_hosts
```

## Development

Create a Python virtual environment and install pre-commit:

```shell
$ python3 -m venv venv
$ source venv/bin/activate
$ pip install pre-commit
$ pre-commit install
$ pre-commit run --all
```
