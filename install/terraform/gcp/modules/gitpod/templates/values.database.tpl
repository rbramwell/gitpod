db:
  host: "${host}"
  password: "${password}"
  port: 3306

components:
  db:
    name: db
    autoMigrate: true
    gcloudSqlProxy:
      enabled: true
      instance: ${instance}
      credentials: ${credentials}
    serviceType: ClusterIP

mysql:
  enabled: false
