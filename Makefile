# extStr variables:
#
#    See "Passing Data to Jsonnet" in https://jsonnet.org/ref/language.html
#
#    We expect, at runtime, to have
#
#    --ext-str argo_namespace=daaas-system \
#    --ext-str namespace=daaas-system \
#    --ext-str url=https://github.com/statcan/aaw-argocd-manifests.git \
#    --ext-str folder=daaas-system \
#    --ext-str targetRevision={local,dev,prod} \
#
# Get the top-level folder in the git repo
ARGOCD_NAMESPACE := $(shell git rev-parse --show-prefix | sed 's~/.*~~')
NAMESPACE := $(shell git rev-parse --show-prefix | sed 's~/.*~~')

# convert git@github.com: to https format urls.
# NOTE: This is assuming you only use the https urls in argo.
URL := $(shell git remote get-url origin | sed 's~git@\(.*\):\(.*\)~https://\1/\2~')
# NOTE: Double $$ since we're in a makefile
FOLDER := $(shell git rev-parse --show-prefix | sed 's~/$$~~')
REVISION := $(shell git rev-parse --abbrev-ref HEAD)

.DEFAULT: template

template: applications.jsonnet
	@find * -type d | jq -Rs '[split("\n") | .[] | select(. != "")]' > applications.libsonnet
	@jsonnet \
		--ext-str argocd_namespace=$(ARGOCD_NAMESPACE) \
		--ext-str namespace=$(NAMESPACE) \
		--ext-str url=$(URL) \
		--ext-str folder=$(FOLDER) \
		--ext-str targetRevision=$(REVISION) \
		applications.jsonnet | jq -cr '.[]' | while read line; do \
			echo '---'; \
			echo $$line | yq -P e - ; \
		done
