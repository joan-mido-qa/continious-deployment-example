resource "helm_release" "metallb" {
  name = "metallb"

  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
}

data "docker_network" "kind" {
  name = "kind"
}

resource "kubectl_manifest" "kind-address-pool" {
  yaml_body = yamlencode({
    "apiVersion" : "metallb.io/v1beta1",
    "kind" : "IPAddressPool",
    "metadata" : { "name" : "kind-address-pool" },
    "spec" : { "addresses" : [replace(tolist(data.docker_network.kind.ipam_config)[0].subnet, ".0.0/16", ".255.0/24")] }
  })

  depends_on = [helm_release.metallb]
}

resource "kubectl_manifest" "kind-advertisement" {
  yaml_body = <<YAML
    apiVersion: metallb.io/v1beta1
    kind: L2Advertisement
    metadata:
        name: kind-advertisement
    YAML

  depends_on = [helm_release.metallb]
}

resource "helm_release" "flux" {
  repository       = "https://fluxcd-community.github.io/helm-charts"
  chart            = "flux2"
  name             = "flux2"
  namespace        = "flux-system"
  create_namespace = true
  version          = "2.9.2"
}

resource "tls_private_key" "flux" {
  depends_on = [helm_release.flux]

  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "flux" {
  depends_on = [tls_private_key.flux]

  title      = "Flux"
  repository = var.github_repository
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}

resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository_deploy_key.flux]

  path = "clusters/develop"
}
