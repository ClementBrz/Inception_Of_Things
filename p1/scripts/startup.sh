#!/bin/bash

# Script to setup your VM with all the main dependencies (Vagrant and virtualBox) 
# for the whole IoT project.

B_YELLOW="\e[1;33m"
B_GREEN="\e[1;32m"
B_GREY="\e[1;30m"
B_RED="\e[1;31m"
RESET="\e[0m"

# Install Vagrant
if vagrant -v; then
    echo -e "${B_GREEN}Vagrant is already installed${RESET}"
else
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor \
        -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install vagrant

    if vagrant -v; then
        echo -e "${B_GREEN}Vagrant successfully installed${RESET}"
    else
        echo -e "${B_RED}Error: failure to install Vagrant${RESET}"
        exit 1
    fi
fi
echo 

# Install VirtualBox
if virtualbox -h; then
    echo -e "${B_GREEN}VirtualBox is already installed${RESET}"
else
    sudo sh -c 'wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg --dearmor'
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
    sudo apt update && sudo apt install virtualbox
    sudo usermod -G vboxusers -a $USER

    if virtualbox -h; then
        echo -e "${B_GREEN}VirtualBox successfully installed${RESET}"
    else
        echo -e "${B_RED}Error: failure to install VirtualBox${RESET}"
        exit 1
    fi
fi
echo 

# Instructions to finalise the installation of virtualbox
echo -e "${B_YELLOW}Si vous avez installé Virtualbox des dépôts Oracle en remplacement de la version des dépôts officiels d'Ubuntu, il peut-être nécessaire de mettre à jour le module DKMS :${RESET}"

echo "sudo /etc/init.d/vboxdrv setup" && echo

echo "You need to reboot your vm for the commands above to take action"

echo 
# Enable nested virtualisation instructions
echo -e "${B_YELLOW}You can enable the nested virtualization feature in one of the following ways:${RESET}"

echo "From the VirtualBox Manager, select the Enable Nested VT-x/AMD-V check box on the Processor tab. To disable the feature, deselect the check box."

echo "Use the --nested-hw-virt option of the VBoxManage modifyvm command to enable or disable nested virtualization. See VBoxManage modifyvm."
