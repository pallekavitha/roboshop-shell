#!/bin/bash

NAMES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
INSTANCE_TYPE=""
IMAGE_ID=ami-081609eef2e3cc958
SECURITY_GROUP_ID=sg-0be4b23bfc8adb5af

# if mysql or mongodb instance_type should be t3.medium , for all others it is t2.micro

for i in "${NAMES[@]}"
do 
    if [[ $i == "mongodb" || $i == "mysql" ]]
    then
        INSTANCE_TYPE="t3.medium"
    else
        INSTANCE_TYPE="t2.micro"
    fi
    echo "Creating $i instance"
    IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID  --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instance[0].PrivateIpAddress')
    echo "created $i instance: $IP_ADDRESS"
done