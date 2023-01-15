#!/bin/bash

#docker
#sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
#sudo apt update
#sudo apt install -y docker-ce
#sudo usermod -aG docker $USER
#sudo systemctl enable docker
#sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#sudo chmod +x /usr/local/bin/docker-compose

#sudo wget -O hello.sql https://raw.githubusercontent.com/conradcorbett/ec2postgres/master/module-ec2/configs/hello.sql
#sudo chmod +x hello.sql
#sudo wget -O mysql.sh https://raw.githubusercontent.com/conradcorbett/ec2postgres/master/module-ec2/configs/mysql.sh
#sudo chmod +x mysql.sh 

mkdir -p /root/${vm_name}
#sudo /usr/local/bin/docker-compose up -d
