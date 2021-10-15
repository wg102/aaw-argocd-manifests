local namespace = std.extVar("namespace");
local image = "openpolicyagent/opa:0.32.0";

[
  {
    apiVersion: "networking.istio.io/v1alpha3",
    kind: "DestinationRule",
    metadata: {
      name: "minio-gateway-opa"
    },
    spec: {
      host: "minio-gateway-opa.%s.svc.cluster.local" % namespace,
      trafficPolicy: {
        tls: {
          mode: "ISTIO_MUTUAL"
        }
      }
    }
  },
  {
    apiVersion: "v1",
    kind: "Service",
    metadata: {
      name: "minio-gateway-opa",
      namespace: namespace,
      labels: {
        "app.kubernetes.io/name": "minio-gateway-opa"
      }
    },
    spec: {
      type: "ClusterIP",
      ports: [
        {
          port: 8181,
          targetPort: 8181,
          protocol: "TCP",
          name: "http"
        }
      ],
      selector: {
        "app.kubernetes.io/name": "minio-gateway-opa"
      }
    }
  },
  {
    apiVersion: "apps/v1",
    kind: "Deployment",
    metadata: {
      name: "minio-gateway-opa",
      namespace: namespace,
      labels: {
        "app.kubernetes.io/name": "minio-gateway-opa"
      }
    },
    spec: {
      replicas: 3,
      selector: {
        matchLabels: {
          "app.kubernetes.io/name": "minio-gateway-opa"
        }
      },
      template: {
        metadata: {
          labels: {
            "app.kubernetes.io/name": "minio-gateway-opa"
          }
        },
        spec: {
          securityContext: {},
          containers: [
            {
              name: "opa",
              securityContext: {},
              image: image,
              imagePullPolicy: "Always",
              args: [
                "run",
                "--ignore=.*",
                "--server",
                "--set=services.default.url=https://$(BUNDLE_STORAGE_ACCOUNT).blob.core.windows.net",
                "--set=services.default.headers.x-ms-version=$(AZURE_STORAGE_SERVICE_VERSION)",
                "--set=services.default.credentials.oauth2.token_url=https://login.microsoftonline.com/$(TENANT_ID)/oauth2/v2.0/token",
                "--set=services.default.credentials.oauth2.client_id=$(CLIENT_ID)",
                "--set=services.default.credentials.oauth2.client_secret=$(CLIENT_SECRET)",
                "--set=services.default.credentials.oauth2.scopes[0]=https://storage.azure.com/.default",
                "--set=bundles.default.resource=$(BUNDLE_FILE_PATH)",
              ],
              env: [
                {
                  name: "MINIO_ADMIN",
                  valueFrom: {
                    secretKeyRef: {
                      name: "minio-gateway-secret",
                      key: "access-key"
                    }
                  }
                },
                {
                  name: "BUNDLE_STORAGE_ACCOUNT",
                  valueFrom: {
                    secretKeyRef: {
                      name: "bundle-secret",
                      key: "bundle-storage-account"
                    }
                  }
                },
                {
                  name: "AZURE_STORAGE_SERVICE_VERSION",
                  valueFrom: {
                    secretKeyRef: {
                      name: "bundle-secret",
                      key: "azure-storage-service-version"
                    }
                  }
                },
                {
                  name: "TENANT_ID",
                  valueFrom: {
                    secretKeyRef: {
                      name: "bundle-secret",
                      key: "tenant_id"
                    }
                  }
                },
                {
                  name: "CLIENT_ID",
                  valueFrom: {
                    secretKeyRef: {
                      name: "bundle-secret",
                      key: "client_id"
                    }
                  }
                },
                {
                  name: "CLIENT_SECRET",
                  valueFrom: {
                    secretKeyRef: {
                      name: "bundle-secret",
                      key: "client_secret"
                    }
                  }
                },
                {
                  name: "BUNDLE_FILE_PATH",
                  valueFrom: {
                    secretKeyRef: {
                      name: "bundle-secret",
                      key: "bundle_file_path"
                    }
                  }
                }
              ],
              ports: [
                {
                  name: "http",
                  containerPort: 8181,
                  protocol: "TCP"
                }
              ],
              livenessProbe: {
                httpGet: {
                  path: "/",
                  port: 8181,
                  scheme: "HTTP"
                },
                initialDelaySeconds: 5,
                timeoutSeconds: 1,
                periodSeconds: 5,
                successThreshold: 1,
                failureThreshold: 3
              },
              readinessProbe: {
                httpGet: {
                  path: "/health?bundle=true",
                  port: 8181,
                  scheme: "HTTP"
                },
                initialDelaySeconds: 5,
                timeoutSeconds: 1,
                periodSeconds: 5,
                successThreshold: 1,
                failureThreshold: 3
              },
              resources: {
                limits: {
                  cpu: "1",
                  memory: "1Gi"
                },
                requests: {
                  cpu: "100m",
                  memory: "200Mi"
                }
              }
            }
          ]
        }
      },
      strategy: {
        type: "RollingUpdate",
        rollingUpdate: {
          maxUnavailable: "25%",
          maxSurge: "25%"
        }
      }
    }
  }
]
