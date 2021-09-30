# This exposes an App for the "App of Apps" pattern
# You use this app to deploy OTHER apps.
#
# The distiction here is that Apps live in the ArgoCD namespace,
# whereas the stuff lives in the target namespace. So you have to
# differentiate betweens "Apps" and "Apps of Apps" otherwise you'll
# Deploy either core applications into the argocd namespace, or else
# you'll deploy Application CRs into an unwatched namespace.

local vars = {
    argocd_namespace: std.extVar('argocd_namespace'),
    namespace: std.extVar('namespace'),
    url: std.extVar('url'),
    folder: std.extVar('folder'),
    targetRevision: std.extVar('targetRevision'),
    domain: std.extVar('domain'),
};

# The variables you're passing down
# https://github.com/google/jsonnet/issues/865
local to_kvs(dict) = std.objectValues(std.mapWithKey(function(k,v) {name: k, value: v}, dict));

# app = {
#    name: str
#    namespace: str    (optional)
#    final: bool       (optional)
# }
#
# If final, deploy to namespace, not argocd_namespace.

{
    extvars: vars,
    app:
    function (app)
        local namespace = if std.objectHas(app, "namespace") then app.namespace else vars.argocd_namespace;
        local folder = if std.objectHas(app, "folder") then vars.folder + "/" + app.folder else vars.folder + "/" + app.name;
        {
            apiVersion: "argoproj.io/v1alpha1",
            kind: "Application",
            metadata: {
                name: app.name,
                namespace: vars.argocd_namespace
            },
            spec: {
                destination: {
                    namespace: if std.objectHas(app, "final") && app.final then namespace else vars.argocd_namespace,
                    server: "https://kubernetes.default.svc"
                },
                project: "default",
                source: {
                    path: folder,
                    repoURL: vars.url,
                    targetRevision: vars.targetRevision,
                    directory: {
                        recurse: false,
                        jsonnet: {
                            extVars: to_kvs(
                                vars + {
                                    folder: folder,
                                    namespace: namespace
                                },
                            )
                        },
                    },
                },
                syncPolicy: {
                    automated: {
                        prune: true,
                        selfHeal: true
                    }
                }
            },
        }
}
