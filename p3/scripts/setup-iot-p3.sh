#!/bin/bash
#https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository

B_YELLOW="\033[1;33m"
B_GREEN="\033[1;32m"
B_GREY="\033[1;30m"
B_RED="\033[1;31m"
RESET="\033[0m"

SETGREY="echo -n "${RESET}${B_GREY}""

result_message() {
    if [ $? -eq 0 ]; then
        echo "${B_GREEN}$1${RESET}"
    else
        echo "${B_RED}$2${RESET}"
        exit 1
    fi
}

echo "${B_YELLOW}Installing docker on $(hostname)${RESET}"

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
result_message "Docker was succesfully installed" "Installation of Docker failed"

sudo systemctl status docker

echo -n "${B_YELLOW}Do you want to create the docker group and add your user to it? Y/N:"
read yesno
if [ "$yesno" = "y" ] || [ "$yesno" = "Y" ]; then
    sudo groupadd docker

    sudo usermod -aG docker $USER
fi


#If you initially ran Docker CLI commands using sudo before adding your user to the docker group, you may see the following error:
#
#WARNING: Error loading config file: /home/user/.docker/config.json -
#stat /home/user/.docker/config.json: permission denied
#This error indicates that the permission settings for the ~/.docker/ directory are incorrect, due to having used the sudo command earlier.
#
#To fix this problem, either remove the ~/.docker/ directory (it's recreated automatically, but any custom settings are lost), or change its ownership and permissions using the following commands:
#
# sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
# sudo chmod g+rwx "$HOME/.docker" -R
