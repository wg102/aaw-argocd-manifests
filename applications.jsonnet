local applications = import 'applications.libsonnet';

local metadata(appName) =
{
    "name": appName,
    "namespace": std.extVar('argocd_namespace'),
};

local spec(appName) =
{
    "destination": {
        "namespace": std.extVar('namespace'),
        "server": "https://kubernetes.default.svc"
    },
    "project": "default",
    "source": {
        "path": std.extVar('folder') + "/" + appName,
        "repoURL": std.extVar('url'),
        "targetRevision": std.extVar('targetRevision'),
        "directory": {
            "jsonnet": {
                "extVars": [
                    {
                        "name": var,
                        "value": std.extVar(var)
                    } for var in [
                        "argocd_namespace",
                        "namespace",
                        "url",
                        "targetRevision"
                    ]
                ] + [
                    {
                        "name": "folder",
                        "value": std.extVar("folder") + "/" + appName
                    },
                ],
            },
        },
    },
    "syncPolicy": {
        "automated": {
            "prune": true,
            "selfHeal": true
        }
    }
};


[
    {
        apiVersion: "argoproj.io/v1alpha1",
        kind: "Application",
        metadata: metadata(app),
        spec: spec(app)
    } for app in applications
]
