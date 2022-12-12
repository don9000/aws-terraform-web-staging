#!/bin/bash

## check apt upto date
apt update
apt install -y awscli
apt install -y net-tools
apt install -y software-properties-common

## set timezone
timedatectl set-timezone Africa/Johannesburg

## load config to environment variables
cd /home/ubuntu
echo ${OLARM_CONFIG_API} | base64 --decode | gunzip > olarm_config1.env
sed 's/\#/\\\#/g' olarm_config1.env | sed 's/"/\\"/g' | tr '\n' ' ' | sed 's/ //g' > olarm_config2.env
echo '' >> /home/ubuntu/.profile
echo -n 'export OLARM_CONFIG_API="' >> /home/ubuntu/.profile
cat olarm_config2.env >> /home/ubuntu/.profile
echo '"' >> /home/ubuntu/.profile
rm olarm_config1.env olarm_config2.env

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
echo ${GITHUB_OLARM_APIV4_DEPLOY_KEY} | base64 --decode | gunzip > ./.ssh/id_rsa_apiv4_github1
chmod 600 /home/ubuntu/.ssh/id_rsa_apiv4_github1
echo "Host api.github.com
 HostName api.github.com
 IdentityFile ~/.ssh/id_rsa_apiv4_github1
" > ./.ssh/config
chmod 600 /home/ubuntu/.ssh/config

## Setup github actions directories
mkdir -p /home/ubuntu/actions-runner/_work/olarm-api/olarm-api

## Ansible
python3 -m pip install --user ansible > ansible-install1.log
ansible-galaxy collection install community.general > ansible-install2.log
aws s3 cp s3://olarm-ansible-playbooks1/ansible-staging-api.yml ./ansible-init.yml --region af-south-1
ansible-playbook ansible-init.yml > ansible-playbook1.log

## Startup PM2
cd  /home/ubuntu/actions-runner/_work/olarm-api/olarm-api
pm2 start server.js --name=apiv4 --output=process/apiv4.log --error=process/apiv4.log
#pm2 save
#sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu

## upgrade!
cd /home/ubuntu
#sudo apt -y upgrade > apt_upgrade.log

EOSU
