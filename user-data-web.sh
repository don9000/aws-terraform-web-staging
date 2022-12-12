#!/bin/bash

## check apt upto date
apt update
apt install -y awscli
apt install -y net-tools
apt install -y software-properties-common

## set timezone
timedatectl set-timezone Africa/Johannesburg

## setup logrotate
printf "/home/ubuntu/process/*.log {\nrotate 21\ndaily\nmissingok\nnotifempty\ncompress\ncopytruncate\ncreate 0640 ubuntu ubuntu\n}\n" > /etc/logrotate.d/olarm-services
mkdir /home/ubuntu/process
chmod 644 /home/ubuntu/process
chmod +x /home/ubuntu/process
chown ubuntu:ubuntu /home/ubuntu/process

## load NODE_ENV to environment variables
echo "export NODE_ENV=production" >> /home/ubuntu/.profile

## run rest not as root user
su ubuntu <<EOSU

## check in home dir
cd /home/ubuntu

## Python Pip install
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py --user > pip-install.log

## load profile for env vars + pip PATH
source ~/.profile

## NPM API Key for private NPM modules
echo "//registry.npmjs.org/:_authToken=${NPM_API_KEY}" > .npmrc

## Github Deploy Key
echo ${GITHUB_OLARM_WEB_PROXY_DEPLOY_KEY} | base64 --decode | gunzip > ./.ssh/id_rsa_proxy_github1
echo ${GITHUB_OLARM_WEB_LOGIN_DEPLOY_KEY} | base64 --decode | gunzip > ./.ssh/id_rsa_login_github1
echo ${GITHUB_OLARM_WEB_USERPORTAL_DEPLOY_KEY} | base64 --decode | gunzip > ./.ssh/id_rsa_userportal_github1
echo ${GITHUB_OLARM_WEB_CC_DEPLOY_KEY} | base64 --decode | gunzip > ./.ssh/id_rsa_cc_github1
chmod 600 /home/ubuntu/.ssh/id_rsa_proxy_github1
chmod 600 /home/ubuntu/.ssh/id_rsa_login_github1
chmod 600 /home/ubuntu/.ssh/id_rsa_userportal_github1
chmod 600 /home/ubuntu/.ssh/id_rsa_cc_github1
echo "Host proxy.github.com
 HostName github.com
 IdentityFile ~/.ssh/id_rsa_proxy_github1

Host login.github.com
 HostName github.com
 IdentityFile ~/.ssh/id_rsa_login_github1

Host userportal.github.com
 HostName github.com
 IdentityFile ~/.ssh/id_rsa_userportal_github1

Host cc.github.com
 HostName github.com
 IdentityFile ~/.ssh/id_rsa_cc_github1
" > ./.ssh/config
chmod 600 /home/ubuntu/.ssh/config

## Setup github actions directories
mkdir -p /home/ubuntu/actions-runner/_work/web-proxy/web-proxy
mkdir -p /home/ubuntu/actions-runner/_work/web-login/web-login
mkdir -p /home/ubuntu/actions-runner/_work/web-userportal/web-userportal
mkdir -p /home/ubuntu/actions-runner/_work/web-commandcentre/web-commandcentre

## Ansible
python3 -m pip install --user ansible > ansible-install1.log
ansible-galaxy collection install community.general > ansible-install2.log
aws s3 cp s3://olarm-ansible-playbooks1/ansible-staging-web.yml ./ansible-init.yml --region af-south-1
ansible-playbook ansible-init.yml > ansible-playbook1.log

## Startup PM2
cd  /home/ubuntu/actions-runner/_work/web-proxy/web-proxy
pm2 start server.js --name=webproxy --output=process/webproxy.log --error=process/webproxy.log
#pm2 save
#sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu

## upgrade!
cd /home/ubuntu
#sudo apt -y upgrade > apt_upgrade.log

EOSU
