local appName = "etcd";

local app = import '../../app.libsonnet';
local vars = app.extvars;

local values = |||
    nameOverride: "minio-gateway"
    commonLabels:
      app: %(namespace)s-etcd
      data.statcan.gc.ca/classification: unclassified
    auth:
      rbac:
        enabled: false
    image:
      # registry: docker.io
      # repository: bitnami/etcd
      # tag: 3.5.0-debian-10-r64
      registry: k8scc01covidacr.azurecr.io
      repository: etcd
      tag: 3.5.0-debian-10-r64
    replicaCount: 3
    persistence:
      enabled: true
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
    #             - minio-gateway-etcd
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
        name: minio-gateway-etcd
      spec:
        host: minio-gateway-etcd.%(namespace)s.svc.cluster.local
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
      chart: "etcd",
      targetRevision: "6.2.9",
      helm: {
        releaseName: "minio-gateway-" + appName,
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
