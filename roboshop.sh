#!/bin/bash 
AMI=ami-0b4f379183e5706b9
SG_ID=sg-0eb63e7e007519cec #replace with your SG ID.
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "paymeny" "dispatch" "web")

for i in "${INSTANCES[@]}"
do 
    echo "instance is $i"
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t3.small"
    else 
        INSTANCE_TYPE="t2.micro"
    fi

    aws ec2 run-instances --image-id ami-0b4f379183e5706b9 --instance-type $INSTANCE_TYPE --security-group-ids sg-0eb63e7e007519cec --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text


done

## aws ec2 run-instances --image-id ami-0b4f379183e5706b9 --count 1 --instance-type t2.micro --security-group-ids sg-0eb63e7e007519cec 
# --tag-specifications 'ResourceType=instance,Tags=[{Key=webserver,Value=production}]'

