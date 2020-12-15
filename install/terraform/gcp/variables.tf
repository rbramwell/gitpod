variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "container_registry" {
  type = object({
    location = string
  })
}

variable "zone_name" {
  type = string
}

variable "kubernetes" {
  type = object({
    namespace = string
  })
  default = {
    namespace = "default"
  }
}

variable "certificate_email" {
  type = string
}

variable "license" {
    type = string
    default = ""
}

variable "database" {
  type = object({
    name = string
  })
}

variable "subdomain" {
  type    = string
  default = "gitpod"
}
