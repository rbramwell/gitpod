locals {
    credentials = {
        key  = data.local_file.privkey.content
        cert = data.local_file.fullchain.content
    }
}


output "credentials" {
    value = jsonencode(local.credentials)
}