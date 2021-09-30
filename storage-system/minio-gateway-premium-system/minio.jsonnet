local appName = "minio";

local app = import '../../app.libsonnet';
local vars = app.extvars;

local values = |||
    ## MinIO(R) Gateway configuration
    nameOverride: "minio-gateway"
    commonLabels:
      app: %(namespace)s-minio
      data.statcan.gc.ca/classification: unclassified
    global:
      minio:
        existingSecret: minio-gateway-secret
    gateway:
      enabled: true
      type: azure
      # autoscaling:
      #   enabled: true
      #   minReplicas: "2"
      #   maxReplicas: "4"
      #   targetCPU: "60"
      #   targetMemory: "60"
      auth:
        azure:
          storageAccountNameExistingSecret: "azure-blob-storage"
          storageAccountNameExistingSecretKey: "storageAccountName"
          storageAccountKeyExistingSecret: "azure-blob-storage"
          storageAccountKeyExistingSecretKey: "storageAccountKey"
    extraEnv:
      - name: MINIO_ETCD_ENDPOINTS
        value: http://%(namespace)s-etcd-headless:2379/
      - name: MINIO_IAM_OPA_URL
        value: http://%(namespace)s-opa:8181/v1/data/httpapi/authz
    image:
      registry: k8scc01covidacr.azurecr.io
      repository: minio
      tag: 2021.5.27-debian-10-r8
      # registry: docker.io
      # repository: bitnami/minio
      # tag: 2021.5.27-debian-10-r8
    ingress:
      enabled: false
      hostname: %(namespace)s.%(domain)s
    resources:
      limits:
        cpu: "2"
        memory: 8Gi
      requests:
        cpu: "2"
        memory: 8Gi
    # nodeSelector:
    #   agentpool: storage
    # affinity:
    #   podAntiAffinity:
    #     preferredDuringSchedulingIgnoredDuringExecution:
    #     - podAffinityTerm:
    #         labelSelector:
    #           matchExpressions:
    #           - key: app
    #             operator: In
    #             values:
    #             - minio-gateway
    #         topologyKey: kubernetes.io/hostname
    #       weight: 100
    # tolerations:
    # - effect: NoSchedule
    #   key: node.statcan.gc.ca/purpose
    #   operator: Equal
    #   value: system
    # - effect: NoSchedule
    #   key: node.statcan.gc.ca/use
    #   operator: Equal
    #   value: storage
    # # - effect: NoSchedule
    # #   key: data.statcan.gc.ca/classification
    # #   operator: Equal
    # #   value: protected-b
    extraDeploy:
    - apiVersion: networking.istio.io/v1alpha3
      kind: DestinationRule
      metadata:
        name: minio-gateway
      spec:
        host: %(namespace)s-minio.%(namespace)s.svc.cluster.local
        trafficPolicy:
          tls:
            mode: ISTIO_MUTUAL
||| % {domain: vars.domain, namespace: vars.namespace};


{
  apiVersion: "argoproj.io/v1alpha1",
  kind: "Application",
  metadata: {
      name: vars.namespace + "-" + appName,
      namespace: vars.argocd_namespace
  },
  spec: {
    project: "default",
    destination: {
      namespace: vars.namespace,
      server: "https://kubernetes.default.svc"
    },
    source: {
      repoURL: "https://charts.bitnami.com/bitnami",
      chart: "minio",
      targetRevision: "7.2.0",
      helm: {
        values: values,
      }
    },
    syncPolicy: {
      automated: {
        prune: true,
        selfHeal: true
      }
    }
  }
}
