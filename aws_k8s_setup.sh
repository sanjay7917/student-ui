#!/bin/bash
apt update -y
apt install unzip -y && apt install curl -y

#AWSCLI INSTALLATION
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

#AWS CONFIURATION
aws configure set aws_access_key_id AKIAVTTFCSQQMYIZP6N6
aws configure set aws_secret_access_key 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
aws configure set default.region us-east-2

#EKSCTL INSTALLATION
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

#EKSCTL INSTALLATION
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin
