{
  apiVersion: "v1",
  kind: "ConfigMap",
  metadata: {
    name: "profile-configurator-vault-agent-config",
    namespace: "daaas-system"
  },
  data: {
    "config.hcl": importstr 'config.hcl'
  }
}
