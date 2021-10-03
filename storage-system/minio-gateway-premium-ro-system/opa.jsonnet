local app = import '../../app.libsonnet';

local appName = app.extvars.namespace + "-opa";

app.app({name: appName, namespace: app.extvars.namespace, folder: "opa", final: true})
