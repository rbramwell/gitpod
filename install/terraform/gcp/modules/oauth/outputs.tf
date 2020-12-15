output "values" {
  value = data.template_file.gitpod_oauth.rendered
}
