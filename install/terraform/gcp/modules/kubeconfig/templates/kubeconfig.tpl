apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${cluster_ca_certificate}
    server: https://${host}
  name: ${name}-cluster
contexts:
- context:
    cluster: ${name}-cluster
    namespace: ${namespace}
    user: ${name}-user
  name: ${name}
current-context: ${name}
kind: Config
preferences: {}
users:
- name: ${name}-user
  user:
    auth-provider:
      name: gcp
      access-token: ${token}
    