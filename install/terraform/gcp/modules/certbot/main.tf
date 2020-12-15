data "local_file" "fullchain" {
    filename = "${path.root}/${var.path}/live/${var.domain}/fullchain.pem"
}

data "local_file" "privkey" {
    filename = "${path.root}/${var.path}/live/${var.domain}/privkey.pem"
}

data "local_file" "cert" {
    filename = "${path.root}/${var.path}/live/${var.domain}/cert.pem"
}

data "local_file" "chain" {
    filename = "${path.root}/${var.path}/live/${var.domain}/chain.pem"
}
