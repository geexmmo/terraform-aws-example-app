# Init
```bash
terraform init
```
# apply
```bash
terraform apply
```
# push image
After ECR has been created, authorize:
```bash
REGION=$(aws ec2 describe-availability-zones | jq '.AvailabilityZones[0].RegionName' -r)
ACCOUNTID=$(aws sts get-caller-identity | jq '.Account' -r)
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNTID.dkr.ecr.$REGION.amazonaws.com
```
Prepare and push image:
```bash
docker pull ghost:4.12.1
IMAGEID=$(docker image ls | grep ghost | awk '{print $3}')
docker tag $IMAGEID $ACCOUNTID.dkr.ecr.$REGION.amazonaws.com/ghost:latest
docker push $ACCOUNTID.dkr.ecr.$REGION.amazonaws.com/ghost:latest
```
ghost-cluster on ECS will come online 

# Dashoboard
Bashboard name is ec2util, as required in task this is the only one dashboard with 7 metrics displayed.
```bash
REGION=us-east-1
DASHBOARD=ec2util
aws cloudwatch get-dashboard --dashboard-name $DASHBOARD --region $REGION | jq -c '.DashboardBody | fromjson' | jq '.widgets[] | [.properties.title, .type]'

[
  "Running Tasks Count",
  "metric"
]
[
  "Service CPU Utilization",
  "metric"
]
[
  null,
  "metric"
]
[
  null,
  "metric"
]
[
  null,
  "metric"
]
[
  null,
  "metric"
]
[
  null,
  "metric"
]
```

# keep in mind
To save money on nat gateway - bastion instance is used as gateway for ECS cluster (subnet routes)   
All configuration of bastion instance is done in 'netinstance.sh'