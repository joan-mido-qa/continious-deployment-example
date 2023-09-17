import filecmp
import subprocess
import tempfile
from pathlib import Path

from kubernetes import client
from kubernetes import config
from python_hosts import Hosts
from python_hosts import HostsEntry


def setup_hosts() -> None:
    entries = []

    config.load_kube_config(config_file="kubeconfig")

    net_api = client.NetworkingV1Api()

    ingresses = net_api.list_ingress_for_all_namespaces().items

    for ingress in ingresses:
        ip = ingress.status.load_balancer.ingress[0].ip
        host = ingress.spec.rules[0].host
        entries.append(
            HostsEntry(
                address=ip,
                names=[host],
                entry_type="ipv4",
                comment=f"evp CLI: kubectl get ingress/{ingress.metadata.name}",
            )
        )

    core_api = client.CoreV1Api()
    services = core_api.list_service_for_all_namespaces().items

    for service in services:
        if service.spec.type == "LoadBalancer":
            ip = service.status.load_balancer.ingress[0].ip
            name = service.metadata.name
            namespace = service.metadata.namespace
            host = f"{name}.{namespace}.local"
            entries.append(
                HostsEntry(
                    address=ip,
                    names=[host],
                    entry_type="ipv4",
                    comment=f"evp CLI: kubectl get service/{service.metadata.name}",
                )
            )

    hosts = Hosts()

    for entry in entries:
        hosts.remove_all_matching(address=entry.address)

        for host in entry.names:
            hosts.remove_all_matching(name=host)

    hosts.add(entries=entries)

    with tempfile.NamedTemporaryFile() as tmp:
        tmp_path = Path(tmp.name)
        hosts.write(tmp_path)

        if not filecmp.cmp(hosts.path, tmp_path):
            subprocess.check_output(
                [
                    "sudo",
                    "cp",
                    "-f",
                    tmp_path,
                    hosts.path,
                ]
            )


if __name__ == "__main__":
    setup_hosts()
