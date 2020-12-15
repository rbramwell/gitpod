variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "database_credentials" {
  type = string
}

variable "storage_credentials" {
  type = string
}

variable "registry_credentials" {
  type = string
}

# variable "certificates_credentials" {
#   type = string
# }

variable "dns_credentials" {
  type = string
}

variable "certificate" {
  type = object({
    name = string
  })
  default = {
    name = "proxy-config-certificates"
  }
}

variable "kubernetes" {
  type = object({
    namespace = string
  })
  default = {
    namespace = "gitpod"
  }
}

variable "values" {
  type = string
}

variable "path" {
  type = string
}

# variable "authProviders" {
#   type = list(
#     object({
#       id            = string
#       host          = string
#       client_id     = string
#       client_secret = string
#       settings_url  = string
#       callback_url  = string
#       type          = string
#     })
#   )
# }

variable "license" {
    type = string
    default = ""
}