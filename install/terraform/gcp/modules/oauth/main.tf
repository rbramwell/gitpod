variable "dns_name" {
  type = string
}

variable "github" {
  type = object({
    client_id     = string
    client_secret = string
  })
}



#
# file: registry.yaml
#

data "template_file" "gitpod_oauth" {
  template = file("${path.module}/templates/values.tpl")
  vars = {
    domain        = var.dns_name
    client_id     = var.github.client_id
    client_secret = var.github.client_secret
  }
}
