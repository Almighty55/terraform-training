#!/bin/bash
#Install BastionZero
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5C358E613982017
sudo add-apt-repository 'deb https://download-apt.bastionzero.com/production/apt-repo stable
main'
sudo apt update
sudo apt install -y bzero
#Update Machine
sudo apt update && sudo apt upgrade -y
sudo do-release-upgrade
#Install Speedtest
sudo apt-get install curl
curl -s https://install.speedtest.net/app/cli/install.deb.sh | sudo bash
sudo apt-get install speedtest
#Install Docker
sudo apt-get update
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu
$(lsb_release -cs) stable"
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
#Secure Machine
sudo apt install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable