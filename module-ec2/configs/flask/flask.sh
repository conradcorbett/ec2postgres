#!/bin/bash
set -ex

sudo systemctl stop firewalld
sudo yum update -y
sudo yum install python3 python3-devel mysql-devel gcc -y
sudo pip3 install -r /root/flaskapp/requirements.txt