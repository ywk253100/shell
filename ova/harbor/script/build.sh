#!/bin/bash
set -e

#Install docker
tdnf install -y docker

systemctl enable docker.service

mkdir -p /var/log/harbor