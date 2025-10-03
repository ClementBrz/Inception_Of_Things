#!/bin/bash
#https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository

B_YELLOW="\e[1;33m"
B_GREEN="\e[1;32m"
B_GREY="\e[1;30m"
B_RED="\e[1;31m"
RESET="\e[0m"

SETGREY="echo -e -n "${RESET}${B_GREY}""

result_message() {
    if [ $? -eq 0 ]; then
        echo -e "${B_GREEN}$1${RESET}"
    else
        echo -e "${B_RED}$2${RESET}"
        exit 1
    fi
}

sudo apt-get update && sudo apt-get upgrade -y

# Install curl if necessary
if command -v curl; then
    echo -e "${B_ORANGE}curl is already installed${RESET}"
else
    sudo apt-get install curl -y
    echo -e "${B_GREEN}curl is now installed${RESET}"
fi

# Install ca-certificates
if dpkg -l | grep ca-certificates; then
    echo -e "${B_GREEN}ca-certificates is already installed${RESET}"
    echo -e -n "${B_YELLOW}Do you want to update ca-certificates? Y/N:${RESET}"
    read yesno
    if [ "$yesno" = "y" ] || [ "$yesno" = "Y" ]; then
        sudo update-ca-certificates
    fi
else
    sudo apt-get install ca-certificates -y
fi

# Install docker
if docker --version; then
    echo -e "${B_GREEN}Docker is already installed!${RESET}"
else
    # Add Docker's official GPG key:
    echo -e "${B_YELLOW}Installing docker on $(hostname)${RESET}"
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    
    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # Install docker
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    result_message "Docker was successfully installed" "Installation of Docker failed"
    
    docker --version || {
        echo -e "${B_RED}Error: docker failed to install${RESET}"
        exit 1
    }
    echo -e "${B_GREEN}docker successfully installed${RESET}"
fi


echo -e '#If you initially ran Docker CLI commands using sudo before adding your user to the docker group, you may see the following error:
#
#WARNING: Error loading config file: /home/user/.docker/config.json -
#stat /home/user/.docker/config.json: permission denied
#This error indicates that the permission settings for the ~/.docker/ directory are incorrect, due to having used the sudo command earlier.
#
#To fix this problem, either remove the ~/.docker/ directory (it is recreated automatically, but any custom settings are lost), or change its ownership and permissions using the following commands:
#
# sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
# sudo chmod g+rwx "$HOME/.docker" -R'


echo -e -n "${B_YELLOW}Do you want to create the docker group and add your user to it? Y/N:${RESET}"
read yesno
if [ "$yesno" = "y" ] || [ "$yesno" = "Y" ]; then
    sudo groupadd docker

    sudo usermod -aG docker $USER
fi

# Install kubectl if necessary
if kubectl version --client; then
    echo -e "${B_GREEN}kubectl is already installed!${RESET}"
else
    if (uname -m | grep "x86_64"); then
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" || {
            echo -e "${B_RED}Error downloading the latest version of kubectl${RESET}"
            exit 1
        }
    else
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl" || {
            echo -e "${B_RED}Error downloading the latest version of kubectl${RESET}"
            exit 1
        }
    fi
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    kubectl version --client || {
        echo -e "${B_RED}Error: kubectl failed to install${RESET}"
        exit 1
    }
    echo -e "${B_GREEN}kubectl was successfully installed${RESET}"
fi

# Install the latest version of k3d
if curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash; then
    echo -e "${B_GREEN}k3d latest release was successfully installed${RESET}"
else
    echo -e "${B_RED}Error: failed installation of k3d latest release${RESET}"
    exit 1
fi

# Create our k3d cluster
if k3d cluster list | grep cluster-p3; then
    echo -e "${B_GREEN}The k3d cluster for p3 has already been created${RESET}"
elif k3d cluster create cluster-p3; then
    echo -e "${B_GREEN}cluster-p3 created successfully!${RESET}"
else
    echo -e "${B_RED}Error: failure to create cluster-p3${RESET}"
    exit 1
fi

# Create argoCD namespace and create argoCD pods in that namespace
if kubectl get namespace | grep argocd; then
    echo -e "${B_GREEN}argocd namespace already exists${RESET}"
else
    kubectl create namespace argocd
fi

if kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml; then
    echo -e "${B_GREEN}ArgoCD services successfully installed!${RESET}"
else
    echo -e "${B_RED}Error: failure to install ArgoCD services${RESET}"
fi

# Install the ArgoCD CLI
if argocd version | grep "argocd: v"; then
    echo -e "${B_GREEN}ArgoCD CLI already installed${RESET}"
else
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64

    if argocd version | grep "argocd: v"; then
        echo -e "${B_GREEN}ArgoCD CLI successfully installed!${RESET}"
    else
        echo -e "${B_RED}Error: failure to install ArgoCD CLI${RESET}"
        exit 1
    fi
fi

# Link argocd to our app
if kubectl apply -f confs/application.yaml; then
    echo -e "${B_GREEN}ArgoCD configuration successful!"
else
    echo -e "${B_RED}Error: failure to configure ArgoCD"
fi

# Forwarding port to be able to access the API server without having to expose it
# It is accessible at https://localhost:8080
echo -e "${B_ORANGE}Waiting for the argocd pods to be running${RESET}"
status=1
while [ $status == 1 ]
do
    if kubectl port-forward svc/argocd-server -n argocd 8080:443; then
        status=0
    fi
    sleep 10
done
