local image = "k8scc01covidacr.azurecr.io/kubeflow-controller:fd3a92c63b1363f946d4b39a37258c4aa3e30fea";

assert std.member(["aaw-dev-cc-00", "aaw-prod-cc-00", "master"], std.extVar('targetRevision'));


local vars = if std.extVar('targetRevision') == "aaw-prod-cc-00" then
      {
         vault_path: "auth/" + std.extVar('targetRevision'),
         oidc_accessor: "auth_oidc_8a2fe3d8",
         minio_instances: "minio_standard_tenant_1,minio_premium_tenant_1"
      }
    else
      {
         vault_path: "auth/aaw-dev-cc-00",
         oidc_accessor: "auth_oidc_6fdc919f",
         minio_instances: "minio_premium,minio_standard,minio_protected_b"
      }
    ;

{
  "apiVersion": "apps/v1",
  "kind": "Deployment",
  "metadata": {
    "name": "profile-configurator",
    "namespace": "daaas-system",
    "labels": {
      "apps.kubernetes.io/name": "profile-configurator"
    }
  },
  "spec": {
    "selector": {
      "matchLabels": {
        "apps.kubernetes.io/name": "profile-configurator"
      }
    },
    "template": {
      "metadata": {
        "labels": {
          "apps.kubernetes.io/name": "profile-configurator"
        },
        "annotations": {
          "vault.hashicorp.com/agent-inject": "true",
          "vault.hashicorp.com/agent-configmap": "profile-configurator-vault-agent-config",
          "vault.hashicorp.com/agent-pre-populate": "false"
        }
      },
      "spec": {
        "serviceAccountName": "profile-configurator",
        "imagePullSecrets": [
          {
            "name": "k8scc01covidacr-registry-connection"
          }
        ],
        "containers": [
          {
            "name": "profile-configurator",
            "image": image,
            "resources": {
              "limits": {
                "memory": "128Mi",
                "cpu": "500m"
              }
            },
            "env": [
              {
                "name": "VAULT_AGENT_ADDR",
                "value": "http://127.0.0.1:8100"
              },
              {
                "name": "MINIO_INSTANCES",
                "value": vars.minio_instances
              },
              {
                "name": "KUBERNETES_AUTH_PATH",
                "value": vars.vault_path
              },
              {
                "name": "OIDC_AUTH_ACCESSOR",
                "value": vars.oidc_accessor
              }
            ]
          }
        ]
      }
    }
  }
}
