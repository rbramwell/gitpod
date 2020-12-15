apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: ${name}
  namespace: ${namespace}
spec:
  secretName: ${name}
  renewBefore: 24h
  dnsNames:
    - "${domain}"
    - "*.${domain}"
    - "*.ws.${domain}"
  issuerRef:
    name: letsencrypt-issuer
    kind: ClusterIssuer