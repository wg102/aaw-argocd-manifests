# Folders and the namespaces to deploy to
local applications = [
    {name: "minio-gateway-standard-system", namespace: "minio-gateway-standard-system"},
    {name: "minio-gateway-premium-system", namespace: "minio-gateway-premium-system"},
];

local app = import '../app.libsonnet';

# End result
[ app.app(application) for application in applications ]
