local appName = std.split(std.thisFile, ".")[0];

local app = import '../../app.libsonnet';

app.app({name: appName, namespace: app.extvars.namespace})
