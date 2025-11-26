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

# Add GitLab's helm repository and install gitlab's chart
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab-release1 gitlab/gitlab \
  -n gitlab \
  --create-namespace \
  -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
  --set global.hosts.domain=gitlab.example.com \
  --set global.hosts.externalIP= \
  --set global.hosts.https=false \
  --timeout 100s
#helm upgrade --install gitlab-release1 gitlab/gitlab \
#    -f gitlab-values.yml \
#    --namespace gitlab \
#    --create-namespace \
#    --timeout 600s

$SET_GREY
echo "Use this password below to login your GitLab instance:${RESET}"
kubectl get secret -n gitlab gitlab-release1-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode > .gitlab_pass

# Forwarding gitlab's port to be able to access it
# It is accessible at https://localhost:8181
echo -e "${B_ORANGE}Waiting for the gitlab's pods to be running${RESET}"
while ! curl -s http://localhost:8181 >/dev/null
do
    kubectl port-forward svc/gitlab-release1-webservice-default -n gitlab 8181:8181 > gitlab-port-forward.log 2>&1 &
    sleep 10
done
echo -e "${B_GREEN}Your gitlab instance is now available at https://localhost:8181${RESET}"

# In order to continue you need to log into your gitlab account.
# Your username is "root" and your password was printed earlier with the `kubectl get secret` command.
# Once this is done create your project with the required files, dev/deployment.yaml and service.yaml.
# Commit those changes and edit your confs/application.yaml file and change the source repo.
# Write "http://gitlab-release1-webservice-default.gitlab.svc.cluster.local:8181/root/<repo_name>.git"
# Edit the path of the directory as well, "dev" instead of "p3/confs/dev"
# All done.
# You can use this password to create a user: oiwureoiyuqw
