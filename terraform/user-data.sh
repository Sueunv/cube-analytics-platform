#!/bin/bash

dnf update -y

dnf install docker -y

systemctl enable docker
systemctl start docker

curl -SL https://github.com/docker/compose/releases/download/v2.39.1/docker-compose-linux-x86_64 \
-o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

yum install amazon-cloudwatch-agent -y

systemctl enable amazon-cloudwatch-agent
