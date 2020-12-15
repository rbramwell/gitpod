variable "project" {
  type = string
}

variable "certmanager" {
  type = object({
    name       = string
    namespace  = string
    chart      = string
    repository = string
    crds_url   = string
  })
  default = {
    name       = "certmanger"
    namespace  = "certmanager"
    chart      = "cert-manager"
    repository = "https://charts.jetstack.io"
    crds_url   = "https://github.com/jetstack/cert-manager/releases/download/v1.0.3/cert-manager.yaml"
  }
}

variable "certificate" {
  type = object({
    name      = string
    email     = string
    namespace = string
    domain    = string
  })
}

variable "kubeconfig" {
  type = string
}