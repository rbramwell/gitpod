variable "project" {
  type = string
}

variable "location" {
  type    = string
  default = "EU"
}

variable "name" {
  type    = string
}

variable "gitpod" {
  type = object({
    namespace = string
  })
  default = {
    namespace = "default"
  }
}

variable "minio_access_key" {
  type    = string
  default = "minio"
}
