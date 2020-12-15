authProviders:
- id: "Git-Hosting"
  host: "github.com"
  protocol: "https"
  type: "GitHub" # alt. "GitLab"
  oauth:
    clientId: "${client_id}"
    clientSecret: "${client_secret}"
    callBackUrl: "https://${domain}/auth/github/callback"
    settingsUrl: "https://github.com/settings/connections/applications/${client_id}"
