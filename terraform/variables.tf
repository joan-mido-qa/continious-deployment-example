variable "kubeconfig" {
  type    = string
  default = "../kubeconfig"
}

variable "github_token" {
  sensitive = true
  type      = string
}

variable "github_owner" {
  type    = string
  default = "joan-mido-qa"
}

variable "github_repository" {
  type    = string
  default = "continious-deployment-example"
}
