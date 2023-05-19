#!/bin/bash
apt update -y
apt install unzip -y && apt install curl -y && apt install openjdk-11-jre -y

#AWSCLI INSTALLATION
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

#EKSCTL INSTALLATION
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

#EKSCTL INSTALLATION
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin

#TOMCAT DEPLOYMENT
aws s3 cp s3://buck12312344/studentapp-2.2-SNAPSHOT*.war .
curl -O https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.74/bin/apache-tomcat-9.0.74.tar.gz
tar -xzvf apache-tomcat-9.0.74.tar.gz -C /opt/                 
mv studentapp-2.2-SNAPSHOT*.war student.war
mv student.war /opt/apache-tomcat-9.0.74/webapps/
sh /opt/apache-tomcat-9.0.74/bin/startup.sh
