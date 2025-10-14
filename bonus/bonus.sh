#!/bin/bash

B_ORANGE="\e[1;34m"
B_YELLOW="\e[1;33m"
B_GREEN="\e[1;32m"
B_GREY="\e[1;30m"
B_RED="\e[1;31m"
RESET="\e[0m"

SETGREY="echo -e -n "${RESET}${B_GREY}""

# Install Helm
if curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3; then
    chmod 700 get_helm.sh
    if ./get_helm.sh; then
        echo -e "${B_GREEN}Helm was successfully installed${RESET}"
    else
        echo -e "${B_RED}Error: failure to run Helm's installation script${RESET}"
        exit 1
    fi
else
    echo -e "${B_RED}Error: failure to retrieve Helm's installation script${RESET}"
    exit 1
fi

# Install GitLab
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm install gitlab gitlab/gitlab \
  --set global.hosts.domain=cbernaze.com \
  --set certmanager-issuer.email=me@cbernaze.com

$SET_GREY
echo "Use this password below to login your GitLab instance:${RESET}"
kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo

kubectl get pods -n gitlab
