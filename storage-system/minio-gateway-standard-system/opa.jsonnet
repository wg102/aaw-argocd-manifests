local appName = "opa";

local app = import '../../app.libsonnet';

app.app({name: appName, namespace: app.extvars.namespace, final: true})
