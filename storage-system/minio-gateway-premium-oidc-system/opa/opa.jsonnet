local namespace = std.extVar("namespace");
local image = "openpolicyagent/opa:0.32.0";
local opa_sync_image = "k8scc01covidacr.azurecr.io/kubeflow-opa-sync:latest";

[
  {
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
      name: "minio-gateway-opa"
    },
    data: {
      "policy.rego": importstr 'policy.rego'
    }
  },
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
                "/policies"
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
              },
              volumeMounts: [
                {
                  name: "policies",
                  readOnly: true,
                  mountPath: "/policies",
                  mountPropagation: "None"
                }
              ]
            },
            {
              name: "kubeflow-opa-sync",
              securityContext: {},
              image: opa_sync_image,
              imagePullPolicy: "Always",
              resources: {
                limits: {
                  cpu: "100m",
                  memory: "200Mi"
                },
                requests: {
                  cpu: "100m",
                  memory: "200Mi"
                }
              }
            }
          ],
          volumes: [
            {
              name: "policies",
              configMap: {
                name: "minio-gateway-opa",
                defaultMode: 420
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
