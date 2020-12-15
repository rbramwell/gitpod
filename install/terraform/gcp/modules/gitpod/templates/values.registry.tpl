components:
  imageBuilder:
    registryCerts: []
    registry:
      name: "eu.gcr.io/${project}"
      secretName: ${secretName}
#      path: secrets/registry-auth.json

  workspace:
    pullSecret:
      secretName: ${secretName}

docker-registry:
  enabled: false

gitpod_selfhosted:
  variants:
    customRegistry: true
