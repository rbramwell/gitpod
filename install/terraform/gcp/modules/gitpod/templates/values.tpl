hostname: ${hostname}
components:
  proxy:
    serviceType: "NodePort"
#    loadBalancerIP: ${loadBalancerIP}
    loadBalancerIP: null
    serviceAnnotations:
      cloud.google.com/backend-config: '{"ports": {"80":"websocket-timeout-backendconfig"}}'
  server:
    serviceAnnotations:
      cloud.google.com/backend-config: '{"ports": {"3000":"websocket-timeout-backendconfig"}}'

installPodSecurityPolicies: true

license: ${license}

branding:
  homepage: ${hostname}
  redirectUrlIfNotAuthenticated: /workspaces/
  redirectUrlAfterLogout: ${hostname}
