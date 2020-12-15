variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type    = string
  default = "gitpod-database"
}

variable "username" {
  type    = string
  default = "gitpod"
}

variable "network" {
  type = object({
    id   = string
    name = string
  })
}

variable "gitpod" {
  type = object({
    serviceaccount = string
    namespace      = string
  })
  default = {
    serviceaccount = "gitpod-database"
    namespace      = "default"
  }
}
