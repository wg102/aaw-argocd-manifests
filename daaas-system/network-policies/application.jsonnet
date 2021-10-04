# Only have dev and prod at the moment
assert std.member(["aaw-dev-cc-00", "aaw-prod-cc-00", "master", "main"], std.extVar('targetRevision'));

local policies_branch = if std.extVar('targetRevision') == "aaw-prod-cc-00" then
    "aaw-prod-cc-00"
  else
    "aaw-dev-cc-00"
  ;

{
  "apiVersion": "argoproj.io/v1alpha1",
  "kind": "Application",
  "metadata": {
    "name": "network-policies",
    "namespace": "daaas-system",
    "annotations": {
      "argocd.argoproj.io/sync-wave": "2"
    }
  },
  "spec": {
    "project": "platform",
    "destination": {
      "namespace": "daaas-system",
      "name": "in-cluster"
    },
    "source": {
      "repoURL": "https://github.com/StatCan/aaw-network-policies.git",
      "path": "environments/" + policies_branch,
      "targetRevision": policies_branch
    },
    "syncPolicy": {
      "automated": {
        "prune": true
      }
    }
  }
}
