#!/bin/bash -xe
exec > >(tee /var/log/cloud-init-output.log|logger -t user-data -s 2>/dev/console) 2>&1

curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -

yum install -y nodejs 
yum install -y jq

SSM_DB_PASSWORD="/ghost/dbpassw"
REGION=$(/usr/bin/curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//')
DB_PASSWORD=$(aws ssm get-parameter --name $SSM_DB_PASSWORD --query Parameter.Value --with-decryption --region $REGION --output text)
aws rds describe-db-instances --region $REGION --db-instance-identifier ghost > /tmp/db.json
DB_URL=$(cat /tmp/db.json | jq '.DBInstances[].Endpoint.Address' | tr -d '"')
DB_USER=$(cat /tmp/db.json | jq '.DBInstances[].MasterUsername' | tr -d '"')
DB_NAME="ghost"
curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -

npm install ghost-cli@latest -g

adduser ghost_user
usermod -aG wheel ghost_user
cd /home/ghost_user/

sudo -u ghost_user ghost install local
sudo -u ghost_user ghost stop

LB_DNS_NAME=$(aws elbv2 describe-load-balancers --region us-east-1 --names ghost-alb | jq '.LoadBalancers[].DNSName' | tr -d '"')

cat << EOF > config.development.json

{
  "url": "http://${LB_DNS_NAME}",
  "server": {
    "port": 2368,
    "host": "0.0.0.0"
  },
  "database": {
    "client": "mysql",
    "connection": {
        "host": "${DB_URL}",
        "port": 3306,
        "user": "${DB_USER}",
        "password": "$DB_PASSWORD",
        "database": "${DB_NAME}"
    }
  },
  "mail": {
    "transport": "Direct"
  },
  "logging": {
    "transports": [
      "file",
      "stdout"
    ]
  },
  "process": "local",
  "paths": {
    "contentPath": "/home/ghost_user/content"
  }
}
EOF

sudo -u ghost_user ghost start