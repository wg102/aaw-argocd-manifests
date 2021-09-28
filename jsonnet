#!/bin/sh

DOMAIN=${DOMAIN:-aaw.cloud.statcan.ca}
ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-$(git rev-parse --show-prefix | sed 's~/.*~~')}"
NAMESPACE=${NAMESPACE:-$(git rev-parse --show-prefix | sed 's~/.*~~')}

# convert git@github.com: to https format urls.
# NOTE: This is assuming you only use the https urls in argo.
URL=${URL:-$(git remote get-url origin | sed 's~git@\(.*\):\(.*\)~https://\1/\2~')}
FOLDER=${FOLDER:-$(git rev-parse --show-prefix | sed 's~/$~~')}
REVISION=${REVISION:-$(git rev-parse --abbrev-ref HEAD)}

# find * -type d | jq -Rs '[split("\n") | .[] | select(. != "")]' \
# > applications.libsonnet

/usr/local/bin/jsonnet \
	--ext-str domain=$DOMAIN \
	--ext-str argocd_namespace=$ARGOCD_NAMESPACE \
	--ext-str namespace=$NAMESPACE \
	--ext-str url=$URL \
	--ext-str folder=$FOLDER \
	--ext-str targetRevision=$REVISION \
	$@
